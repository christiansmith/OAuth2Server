/**
 * Module dependencies
 */

var client   = require('../config/redis')
  , Modinha  = require('modinha')
  , Document = require('modinha-redis')
  , Service  = require('./Service')
  ;


/**
 * Model definition
 */

var Scope = Modinha.define('scopes', {
  url:         { type: 'string', required: true, format: 'url', uniqueId: true },
  description: { type: 'string', required: true },
  serviceId:   { type: 'string', reference: Service }
});


/**
 * Document persistence
 */

Scope.extend(Document);
Scope.__client = client;


/**
 * Exports
 */

module.exports = Scope;