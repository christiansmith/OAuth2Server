/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , RedisDocument = require('./RedisDocument')
  , random  = Modinha.defaults.random
  ;


/**
 * Model definition
 */

var Credentials = Modinha.define('credentials', {
  key:    { type: 'string', required: true, default: random(10), uniqueId: true },
  secret: { type: 'string', required: true, default: random(10) },
  role:   { type: 'string', required: true, enum: ['app', 'service', 'admin'] }
});


/**
 * Document persistence
 */

Credentials.extend(RedisDocument);


/**
 * Exports
 */

module.exports = Credentials;