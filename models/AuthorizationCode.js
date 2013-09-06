/**
 * Module dependencies
 */

var Model = require('modinha');


/**
 * Model definition
 */

var AuthorizationCode = Model.extend(null, {
  schema: {
    client_id:  { type: 'string', required: true },
    code:       { type: 'string', required: true },
    expires_at: { type: 'any' }
  }
});


/**
 * Exports
 */

module.exports = AuthorizationCode;
