/**
 * Module dependencies
 */

var Modinha     = require('modinha')
  , Credentials = require('./Credentials')
  , Document    = require('modinha-redis')
  ;


/**
 * Model definition
 */

var Service = Modinha.define('services', {
  uri:         { type: 'string', required: true },
  key:         { type: 'string', private: true },
  description: { type: 'string' }
});


/**
 * Document persistence
 */

Service.extend(Document);


/**
 * Create service
 */

Service.insert = function (data, options, callback) {
  var collection = this.collection
    , service    = Service.initialize(data, {private: true})
    , validation = service.validate()
    ;

  if (!callback) {
    callback = options;
    options = {};
  }

  // handle invalid data
  if (!validation.valid) { return callback(validation); }  

  Credentials.insert({ role: 'service' }, function (err, credentials) {
    if (err) { return callback(err); }

    // associate the service with new credentials
    service.key = credentials.key;

    // store and index 
    var multi = Service.__client.multi();

    multi.hset(collection, service._id, Service.serialize(service));
    
    Service.index(multi, service);

    multi.exec(function (err, result) {
      if (err) { return callback(err); }
      
      // provide the secret without saving it in service
      service.secret = credentials.secret;
      callback(null, service);
    });
  });
};


/**
 * Exports
 */

module.exports = Service;