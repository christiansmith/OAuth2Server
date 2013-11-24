/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , Document = require('modinha-redis')
  ;


/**
 * Model definition
 */

var Scope = Modinha.define('scopes', {
  url:         { type: 'string', required: true, format: 'url', uniqueId: true },
  description: { type: 'string', required: true },
  serviceId:   { type: 'string' }
});


/**
 * Document persistence
 */

Scope.extend(Document);


/**
 * Exports
 */

module.exports = Scope;