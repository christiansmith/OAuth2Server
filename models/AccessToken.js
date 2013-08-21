/**
 * Module dependencies
 */

var Model = require('./Model')
  , crypto = require('crypto')
  , util = require('util')
  ;


/**
 * Model definition
 */

var AccessToken = Model.extend(null, {
  schema: {
    client_id:      { type: 'string', required: true },
    user_id:        { type: 'string', required: true },
    access_token:   { type: 'string' },
    token_type:     { type: 'string', enum: ['bearer', 'mac'], default: 'bearer' },
    expires_at:     { type: 'any' },
    refresh_token:  { type: 'string' },
    scope:          { type: 'string' },
    created:        { type: 'any' },
    modified:       { type: 'any' }
  }
});


/**
 * Issue access token
 */

AccessToken.issue = function(client, user, options, callback) {
  if (callback === undefined) {
    callback = options;
    options = {};
  }

  this.create({
    client_id:      client._id,
    user_id:        user._id,
    access_token:   crypto.randomBytes(10).toString('hex'),
    expires_at:     new Date(Date.now() + 4 * 3600 * 1000),
    refresh_token:  crypto.randomBytes(10).toString('hex'),
    scope:          options.scope
  }, function (err, token) {
    if (err) { return callback(err); }
    callback(null, token);
  });
};


/**
 * Verify access token
 */

AccessToken.verify = function (access_token, client_id, scope, callback) {
  this.find({ access_token: access_token }, function (err, token) {
    if (!token) { 
      return callback(new InvalidTokenError('Unknown access token')); 
    }

    if (client_id !== token.client_id) { 
      return callback(new InvalidTokenError('Client mismatch')); 
    }
    
    if (new Date() > token.expires_at) { 
      return callback(new InvalidTokenError('Expired access token')); 
    }

    if (token.scope.indexOf(scope) === -1) {
      return callback(new InsufficientScopeError());
    }

    callback(null, true);
  });
};


/**
 * InvalidTokenError
 */

function InvalidTokenError(description) {
  this.name = 'InvalidTokenError';
  this.message = 'invalid_token';
  this.description = description;
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InvalidTokenError, Error);


/**
 * InsufficientScopeError
 */

function InsufficientScopeError() {
  this.name = 'InsufficientScopeError';
  this.message = 'insufficient_scope';
  this.description = 'Insufficient scope';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InsufficientScopeError, Error);


/**
 * Exports
 */

module.exports = AccessToken;