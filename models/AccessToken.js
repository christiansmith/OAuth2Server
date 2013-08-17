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

function AccessToken (attrs) {
  var schema = AccessToken.schema
    , self = this;

  self.token_type = 'bearer';

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
}


/**
 * Schema
 */

AccessToken.schema = {
  client_id:      { type: 'string', required: true },
  access_token:   { type: 'string' },
  token_type:     { type: 'string', enum: ['bearer', 'mac'] },
  expires_at:     { type: 'any' },
  refresh_token:  { type: 'string' },
  scope:          { type: 'string' },
  created:        { type: 'any' },
  modified:       { type: 'any' }
};


/**
 * Validate data against the AccessToken schema.
 */

AccessToken.prototype.validate = function() {
  return validate(this, AccessToken.schema);
};


/**
 * Create access token
 */

AccessToken.create = function (attrs, callback) {
  var token = new AccessToken(attrs)
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
 * Find access token
 */

AccessToken.find = function (conditions, options, callback) {
  if (callback === undefined) {
    callback = options;
    options = {};
  }

  backend.find(conditions, function (err, data) {
    if (err) { return callback(err); }
    if (!data) { return callback(null, data); }
    callback(null, new AccessToken(data));
  });
};



/**
 * Verify access token
 */

AccessToken.prototype.verify = function (client_id, access_token, scope) {
  return client_id    === this.client_id 
      && access_token === this.access_token
      && new Date()   <   this.expires_at
      && scope        !== ''
      && this.scope.indexOf(scope) !== -1
      ;
};

// untested draft of async verifiy, with custom errors
AccessToken.verify = function (access_token, client_id, scope, callback) {
  AccessToken.find({ access_token: access_token }, function (err, token) {
    var invalid = !token 
               || client_id    !== token.client_id
               || access_token !== token.access_token
               || new Date()   < token.expires_at
                ;

    if (invalid) { 
      return callback(new InvalidTokenError()); 
    }

    if (token.scope.indexOf(scope) === -1) {
      return callback(new InsufficientScopeError());
    }

    callback(null, true);
  });
};


/**
 * Exports
 */

AccessToken.backend = backend;
module.exports = AccessToken;