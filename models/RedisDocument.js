/**
 * Module dependencies
 */

var redis  = require('redis')
  , client = redis.createClient()
  ;


/**
 * Constructor mixin
 */

function RedisDocument () {}


/**
 * Create a document
 */

RedisDocument.create = function (data, callback) {
  var Model       = this
    , schema      = Model.schema
    , collection  = Model.collection
    , uniqueId    = Model.uniqueId
    , instance    = Model.initialize(data, { private: true })
    , validation  = instance.validate()
    ;

  // handle invalid data
  if (!validation.valid) { return callback(validation); }

  // set timestamps
  var timestamp = Date.now();
  if (!instance.created)  { instance.created  = timestamp; }
  if (!instance.modified) { instance.modified = timestamp; }  

  // batch operations
  var multi = client.multi();
  multi.hset(collection, instance[uniqueId], Model.serialize(instance));
  multi.zadd(collection + ':' + uniqueId, instance.timestamp, instance[uniqueId]);

  // generate index meta data once when the 
  // model is defined, instead of here
  var keys = Object.keys(schema);
  keys.forEach(function (key) {
    if (schema[key].index === 'secondary') {
      multi.hset(collection + ':' + key, instance[key], instance[uniqueId]);
    }
  });

  multi.exec(function (err, result) {
    if (err) { return callback(err); }
    callback(null, instance);
  });
};


/**
 * Get a document or documents by id
 */

RedisDocument.get = function (ids, options, callback) {
  var Model = this
    , collection = Model.collection
    ;

  // optional options argument
  if (!callback) {
    callback = options;
    options = {};
  }

  // return an object instead of an array
  // if the first argument is a string
  if (typeof ids === 'string') { 
    options.first = true;
  }

  // don't call hmget with undefined ids
  if (!ids) { 
    return callback(null, null); 
  }

  // don't call hmget with an empty array
  if (Array.isArray(ids) && ids.length === 0) {
    return callback(null, [])
  }

  // if redis responds with undefined or null
  // values, initialization should provide null
  // instead of an instance
  options.nullify = true;

  // send redis the hash multiget command
  client.hmget(collection, ids, function (err, result) {
    if (err) { return callback(err); }
    callback(null, Model.initialize(result, options));
  });
};


/**
 * Find
 */

RedisDocument.find = function (options, callback) {
  var Model      = this
    , collection = Model.collection
    ;

  // optional options argument
  if (!callback) {
    callback = options;
    options = {};
  }

  // assign the default index if none is provided 
  var index = options.index || collection + ':_id';

  // default page and size
  var page = options.page || 1
    , size = parseInt(options.size) || 50
    ;

  // calculate start and end index
  // for the sorted set range lookup
  var startIndex = (size * (page - 1))
    , endIndex   = (startIndex + size) - 1;    
    ;

  client.zrevrange(index, startIndex, endIndex, function (err, ids) {
    if (err) { return callback(err); }

    // handle empty results
    if (!ids || ids.length === 0) { 
      return callback(null, []); 
    } 

    // get by id
    Model.get(ids, function (err, instances) {
      if (err) { return callback(err); }
      callback(null, instances);
    });
  });
};

/**
 * Update
 */

RedisDocument.update = function (data, callback) {
  var Model      = this
    , collection = Model.collection
    , uniqueId   = Model.uniqueId
    ;

  Model.get(data[uniqueId], function (err, instance) {
    if (err) { return callback(err); }

    // what if the instance is not found?
    instance.merge(data);

    client.multi()
      .hset(collection, instance[uniqueId], Model.serialize(instance))
      .exec(function (err) {
        if (err) { return callback(err); }
        callback(null, instance);
      });
  });
};


/**
 * Destroy
 */

RedisDocument.destroy = function (id, callback) {
  client.multi()
    .hdel(this.collection, id)
    .exec(function (err) {
      if (err) { callback(err); }
      callback(null);
    });
};


/**
 * Exports
 */

module.exports = RedisDocument;
