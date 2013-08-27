/**
 * Module dependencies
 */

var Model = require('./Model')
  , crypto = require('crypto')
  ;


/**
 * Model definition
 */

var Resource = Model.extend(null, {
  schema: {
    _id:         { type: 'any' },
    user_id:     { type: 'string', required: true },
    uri:         { type: 'string', required: true },
    secret:      { type: 'string', required: true },
    description: { type: 'string' },    
    created:     { type: 'any' },
    modified:    { type: 'any' }
  }
});


/**
 * Resource Registration
 */

Resource.register = function (attrs, callback) {
  attrs.secret = crypto.randomBytes(10).toString('hex');
  Resource.create(attrs, function (err, resource) {
    if (err) { return callback(err); }
    callback(null, resource);
  });
};


/**
 * Exports
 */

module.exports = Resource;