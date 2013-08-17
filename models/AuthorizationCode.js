/**
 * Module dependencies
 */

var validate  = require('../lib/validate')
  , Backend   = require('./Backend')
  , backend = new Backend()
  ;


/**
 * Constructor
 */

function AuthorizationCode (attrs) {
  var schema = AuthorizationCode.schema
    , self = this;

  function set(keys, source, target) {
    keys.forEach(function (key) {
      if (attrs[key] && schema[key].properties) {
        if (!self[key]) { 
          self[key] = {}; 
        }
        set(Object.keys(schema[key].properties), attrs[key], self[key]);
      } else {
        if (source[key]) { 
          target[key] = source[key]; 
        }
      }
    });
  }

  if (attrs) {
    set(Object.keys(schema), attrs, self);
  } 
};


/**
 * Schema
 */

AuthorizationCode.schema = {
  client_id:  { type: 'string', required: true },
  code:       { type: 'string', required: true },
  expires_at: { type: 'any' },
  created:    { type: 'any' },
  modified:   { type: 'any' }
};


/**
 * Validate data against the AuthorizationCode schema.
 */

AuthorizationCode.prototype.validate = function() {
  return validate(this, AuthorizationCode.schema);
};


/**
 * Create authorization
 */

AuthorizationCode.create = function (attrs, callback) {
  var token = new AuthorizationCode(attrs)
    , validation = token.validate();

  if (!validation.valid) { return callback(validation); }

  var now = new Date();
  token.created = now;
  token.modified = now;

  backend.save(token, function (err, token) {
    if (err) { return callback(err); }
    callback(null, token);
  });
};


/**
 * Find authorization
 */

AuthorizationCode.find = function (conditions, options, callback) {
  if (callback === undefined) {
    callback = options;
    options = {};
  }

  backend.find(conditions, function (err, data) {
    if (err) { return callback(err); }
    if (!data) { return callback(null, data); }
    callback(null, new AuthorizationCode(data));
  });
};


/**
 * Exports
 */

AuthorizationCode.backend = backend;
module.exports = AuthorizationCode;