/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , Credentials = require('./HTTPCredentials')
  ;


/**
 * Model definition
 */

var Client = Modinha.extend('Clients', null, {
  schema: {
  	type:        { 
      type: 'string', 
      required: true, 
      enum: ['confidential', 'public', 'trusted'] 
    },
  	name:         { type: 'string' },
  	website:      { type: 'string' },
  	description:  { type: 'string' },
  	logo:         { type: 'string' },
  	terms:        { type: 'boolean' },
    redirect_uri: { type: 'string' },
    key:          { type: 'string', private: true }
  }
});


/**
 * Issue credentials
 */

Client.before('create', function (client, attrs, callback) {
  Credentials.create({ role: 'client' }, function (err, credentials) {
    if (err) { return callback(err); }
    client.key = credentials.key;
    callback(null, credentials);
  });
});


/**
 * Include secret in creation result
 */

Client.before('complete', function (client, attrs, result, callback) {
  if (result.beforeCreate) {
    var credentials = result.beforeCreate[0];
    client.secret = credentials.secret;
  }

  callback(null);
});


/**
 * Exports
 */

module.exports = Client;