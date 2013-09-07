/**
 * Module dependencies
 */

var Model = require('modinha')
  , crypto = require('crypto')
  ;


/**
 * Model definition
 */

var Resource = Model.extend(null, {
  schema: {
    user_id:     { type: 'string', required: true },
    uri:         { type: 'string', required: true },
    secret:      { type: 'string' },
    description: { type: 'string' }
  }
});


/**
 * Generate the secret
 */

Resource.before('create', function () {
  this.secret = crypto.randomBytes(10).toString('hex');
});


/**
 * Exports
 */

module.exports = Resource;