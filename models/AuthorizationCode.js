/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , random  = Modinha.defaults.random
  ;


/**
 * Model definition
 */

var AuthorizationCode = Modinha.extend(null, {
  schema: {
    client_id:  { type: 'string', required: true },
    code:       { type: 'string', required: true, default: random },
    expires_at: { type: 'any' }
  }
});


/**
 * Exports
 */

module.exports = AuthorizationCode;