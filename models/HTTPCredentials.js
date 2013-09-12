/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , random  = Modinha.defaults.random
  ;


/**
 * Model definition
 */

var HTTPCredentials = Modinha.extend('HTTPCredentials', null, {
  schema: {
    key:    { type: 'string', required: true, default: random },
    secret: { type: 'string', required: true, default: random },
    role:   { type: 'string', required: true }
  },
  uniqueID: 'key'
});


/**
 * Exports
 */

module.exports = HTTPCredentials;