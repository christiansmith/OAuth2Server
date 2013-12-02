/**
 * Module dependencies
 */

var client      = require('../config/redis')
  , Modinha     = require('modinha')
  , Credentials = require('./Credentials')
  , Document    = require('modinha-redis')
  ;


/**
 * Model definition
 */

var App = Modinha.define('apps', {
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
  key:          { type: 'string', private: true, unique: true }
});


/**
 * Document persistence
 */

App.extend(Document);
App.__client = client;

/**
 * Create app
 */

App.insert = function (data, options, callback) {
  var collection = this.collection
    , app        = App.initialize(data, {private: true})
    , validation = app.validate()
    ;

  if (!callback) {
    callback = options;
    options = {};
  }

  // handle invalid data
  if (!validation.valid) { return callback(validation); }

  Credentials.insert({ role: 'app' }, function (err, credentials) {
    if (err) { return callback(err); }

    // associate the app with new credentials
    app.key = credentials.key;

    // store and index 
    var multi = App.__client.multi();
    multi.hset(collection, app._id, App.serialize(app));

    App.index(multi, app);

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