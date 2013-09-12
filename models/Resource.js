/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , random  = Modinha.defaults.random  
  ;


/**
 * Model definition
 */

var Resource = Modinha.extend('Resources', null, {
  schema: {
    user_id:     { type: 'string', required: true },
    uri:         { type: 'string', required: true },
    secret:      { type: 'string', default: random },
    description: { type: 'string' }
  }
});


/**
 * Exports
 */

module.exports = Resource;