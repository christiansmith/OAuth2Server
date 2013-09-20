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
    uri:         { type: 'string', required: true },
    scopes:      { type: 'array',  required: true },
    secret:      { type: 'string', default: random },
    description: { type: 'string' }
  }
});


/**
 * Exports
 */

module.exports = Resource;