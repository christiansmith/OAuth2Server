/**
 * Module dependencies
 */

var client   = require('../config/redis')
  , Modinha  = require('modinha')
  , Document = require('modinha-redis')
  ;


/**
 * Model definition
 */

var Role = Modinha.define('roles', {
  name: { type: 'string', required: true }
});


/**
 * Document persistence
 */

Role.extend(Document);
Role.__client = client;


/**
 * Role intersections
 */

Role.intersects('accounts');
Role.intersects('scopes', '_id');

/**
 * Exports
 */

module.exports = Role;
