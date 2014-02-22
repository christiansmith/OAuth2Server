/**
 * Module dependencies
 */

var client   = require('../config/redis')
  , Modinha  = require('modinha')
  , Document = require('modinha-redis')
  //, random   = Modinha.defaults.random
  ;


/**
 * Model definition
 */

var Group = Modinha.define('groups', {
  name: { type: 'string', required: true }
});


/**
 * Document persistence
 */

Group.extend(Document);
Group.__client = client;


/**
 * Group accounts
 */

Group.intersects('accounts');
Group.intersects('apps');


/**
 * Exports
 */

module.exports = Group;
