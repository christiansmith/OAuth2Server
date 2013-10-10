/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , Credentials = require('./HTTPCredentials') 
  ;


/**
 * Model definition
 */

var Resource = Modinha.extend('Resources', null, {
  schema: {
    uri:         { type: 'string', required: true },
    scopes:      { type: 'array',  required: true },
    description: { type: 'string' },
    key:         { type: 'string', private: true }
  }
});


/**
 * Issue credentials
 */

Resource.before('create', function (resource, attrs, callback) {
  Credentials.create({ role: 'resource' }, function (err, credentials) {
    if (err) { return callback(err); }
    resource.key = credentials.key;
    callback(null, credentials);
  });
});


/**
 * Include secret in creation result
 */

Resource.before('complete', function (resource, attrs, result, callback) {
  if (result.beforeCreate) {
    var credentials = result.beforeCreate[0];
    resource.secret = credentials.secret;
  }

  callback(null);
});


/**
 * Exports
 */

module.exports = Resource;