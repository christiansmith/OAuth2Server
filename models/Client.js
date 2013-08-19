/**
 * Module dependencies
 */

var Model = require('./Model');


/**
 * Model definition
 */

var Client = Model.extend(null, {
  schema: {
    _id:         { type: 'any' },
    type:        { type: 'string', enum: ['confidential', 'public'], required: true },
    name:        { type: 'string' },
    website:     { type: 'string' },
    description: { type: 'string' },
    logo:        { type: 'string' },
    terms:       { type: 'boolean' },
    secret:      { type: 'string' },
    created:     { type: 'any' },
    modified:    { type: 'any' }
  }
});


/**
 * Exports
 */

module.exports = Client;