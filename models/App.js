/**
 * Module dependencies
 */

var redis         = require('redis')
  , client        = redis.createClient()
  , Modinha       = require('modinha')
  , Credentials   = require('./Credentials')
  , RedisDocument = require('./RedisDocument')
  ;


/**
 * Model definition
 */

var App = Modinha.define('apps', {
  _id:          { type: 'string', default: Modinha.defaults.uuid, format: 'uuid' },
  type:         { 
                  type: 'string', 
                  required: true, 
                  enum: [
                    'confidential', 
                    'public', 
                    'trusted'
                  ] 
                },
  name:         { type: 'string' },
  website:      { type: 'string' },
  description:  { type: 'string' },
  logo:         { type: 'string' },
  terms:        { type: 'boolean' },
  redirect_uri: { type: 'string' },
  key:          { type: 'string', private: true },
  created:      { type: 'number' },
  modified:     { type: 'number' }
});


/**
 * Document persistence
 */

App.extend(RedisDocument);


/**
 * Create app
 */

App.create = function (data, callback) {
  var collection = this.collection
    , app        = App.initialize(data, {private: true})
    , validation = app.validate()
    ;

  // handle invalid data
  if (!validation.valid) { return callback(validation); }

  // set timestamps
  var timestamp = Date.now();
  if (!app.created)  { app.created  = timestamp; }
  if (!app.modified) { app.modified = timestamp; }  

  Credentials.create({ role: 'app' }, function (err, credentials) {
    if (err) { return callback(err); }

    // associate the app with new credentials
    app.key = credentials.key;

    // store and index 
    var multi = client.multi();
    multi.hset(collection, app._id, App.serialize(app));
    multi.zadd(collection + ':_id', timestamp, app._id);

    multi.exec(function (err, result) {
      if (err) { return callback(err); }
      
      // provide the secret without saving it in app
      app.secret = credentials.secret;
      callback(null, app);
    });
  });
};



/**
 * Exports
 */

module.exports = App;