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

  // store the instance
  multi.hset(collection, instance[uniqueId], Model.serialize(instance));

  // index the unique identifier
  multi.zadd(collection + ':' + uniqueId, instance.created, instance[uniqueId]);

  // generate index meta data once when the 
  // model is defined, instead of here
  var keys = Object.keys(schema);
  keys.forEach(function (key) {
    var property = schema[key];

    // unique index
    if (property.unique) {
      multi.hset(collection + ':' + key, instance[key], instance[uniqueId]);
    }

    // secondary index
    if (property.secondary) {
      multi.zadd(collection + ':' + key + ':' + instance[key], timestamp, instance[uniqueId])
    }


    // referenced object index
    if (property.references) {
      var index = property.references.collection;
      index += ':'
      index += instance[key]
      index += ':'
      index += collection
      multi.zadd(index, timestamp, instance[uniqueId]);
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
 *
 * Questions:
 *
 * 1. What guarantees should this method provide?
 * 2. Should we bother looking up the instance and mutating?
 *    Or should we assume we have a complete object and just write?
 *    - overwriting would defeat the purpose of maintaining two timestamps,
 *      but do we really need them in general?
 * 3. Should we provide two methods for this?
 *    Is CRUD even the right thing to be doing?
 *    Maybe this should be closer to key/value semantics
 * 4. How do we deal with updating affected indexes?
 * 5. If the index is a sorted set, do we change the score? 
 *    (reindex modified or created timestamp)
 * 6. Exposed as a REST resource, should we have both PUT and PATCH to differentiate?
 */

RedisDocument.update = function (data, callback) {
  var Model      = this
    , collection = Model.collection
    , uniqueId   = Model.uniqueId
    ;

  Model.get(data[uniqueId], function (err, instance) {
    if (err) { return callback(err); }

    // what if the instance is not found?
    
    // merge the new values into the instance
    instance.merge(data);

    // validate the mutated instance
    var validation = instance.validate();
    if (!validation.valid) { return callback(validation); }

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
 *
 * Questions: 
 * 1. how do we deal with indexes?
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
 * Post Extend
 */

RedisDocument.__postExtend = function () {
  var Model = this
    , collection = Model.collection
    , schema = Model.schema
    ;

  Object.keys(schema).forEach(function (key) {
    var property = schema[key];

    // add a findByUnique method
    if (property.unique) {
      var method = 'findBy' + key.charAt(0).toUpperCase() + key.slice(1);
      Model[method] = findByUnique(collection, key);
    }

    // add a findBySecondary method
    if (property.secondary) {
      var method = 'findBy' + key.charAt(0).toUpperCase() + key.slice(1);
      Model[method] = findBySecondary(collection, key);
    }
  
    // add a findReferencedObject method
    if (property.references) {

    }

  });

  // add timestamps to schema
  var timestamp = { type: 'number', default: Model.defaults.timestamp }
  if (!schema.created) { schema.created = timestamp; }
  if (!schema.modified) { schema.modified = timestamp; }
};


/**
 * Return a method to find documents by unique index
 */

function findByUnique (collection, key) {
  var index = collection + ':' + key;

  return function (value, options, callback) {
    var Model = this;

    if (!callback) {
      callback = options;
      options = {};
    }

    client.hget(index, value, function (err, id) {
      if (err) { return callback(err); }
    
      Model.get(id, options, function (err, instance) {
        if (err) { return callback(err); }
        callback(null, instance);
      });
    });

  };

};


/**
 * Return a method to find documents by secondary index
 */

function findBySecondary (collection, key) {
  return function (value, callback) {
    var Model = this
      , index = collection + ':' + key + ':' + value
      ;

    Model.find({ index: index }, function (err, instances) {
      if (err) { return callback(err); }
      callback(null, instances);
    })
  }
}


/**
 * Exports
 */

module.exports = RedisDocument;
