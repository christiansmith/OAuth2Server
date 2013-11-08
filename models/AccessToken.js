/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , RedisDocument = require('./RedisDocument')
  , random  = Modinha.defaults.random
  , util    = require('util')
  ;


/**
 * Model definition
 */

var AccessToken = Modinha.define('tokens', {
  accessToken:  { type: 'string', required: true, default: random(10), uniqueId: true },
  tokenType:    { type: 'string', enum: ['bearer', 'mac'], default: 'bearer' },
  appId:        { type: 'string', required: true },
  accountId:    { type: 'string', required: true },
  scope:        { type: 'string' }
//  client_id:      { type: 'any', required: true },
//  user_id:        { type: 'any', required: true },
//  access_token:   { type: 'string', default: random },
//  token_type:     { type: 'string', enum: ['bearer', 'mac'], default: 'bearer' },
//  expires_at:     { type: 'any' },
//  refresh_token:  { type: 'string', default: random },
//  scope:          { type: 'string' }

});


/**
 * Document persistence
 */

AccessToken.extend(RedisDocument);


/**
 * Issue access token
 */

AccessToken.issue = function (app, account, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }

  this.create({
    appId: app._id,
    accountId: account._id,
    scope: options.scope
  }, function (err, token) {
    if (err) { return callback(err); }
    callback(null, token);
  })
};

//AccessToken.issue = function(client, user, options, callback) {
//  if (callback === undefined) {
//    callback = options;
//    options = {};
//  }
//
//  this.create({
//    client_id:      client._id,
//    user_id:        user._id,
//    expires_at:     new Date(Date.now() + 4 * 3600 * 1000),
//    scope:          options.scope
//  }, function (err, token) {
//    if (err) { return callback(err); }
//    callback(null, token);
//  });
//};


/**
 * Verify access token
 */

//AccessToken.verify = function (access_token, scope, callback) {
//  this.find({ access_token: access_token }, function (err, token) {
//    if (!token) { 
//      return callback(new InvalidTokenError('Unknown access token')); 
//    }
//    
//    if (new Date() > token.expires_at) { 
//      return callback(new InvalidTokenError('Expired access token')); 
//    }
//
//    if (token.scope.indexOf(scope) === -1) {
//      return callback(new InsufficientScopeError());
//    }
//
//    callback(null, token);
//  });
//};


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