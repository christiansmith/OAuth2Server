/**
 * Module dependencies
 */

var client   = require('../config/redis')
  , Modinha  = require('modinha')
  , Document = require('modinha-redis')
  , random   = Modinha.defaults.random
  , InvalidTokenError = require('../errors/InvalidTokenError')
  , InsufficientScopeError = require('../errors/InsufficientScopeError')
  ;


/**
 * Model definition
 */

var Token = Modinha.define('tokens', {
  access:    { type: 'string', required: true, default: random(10), uniqueId: true },
  type:      { type: 'string', enum: ['bearer', 'mac'], default: 'bearer' },
  appId:     { type: 'string', required: true },
  accountId: { type: 'string', required: true },
  scope:     { type: 'string' }
});


/**
 * Document persistence
 */

Token.extend(Document);
Token.__client = client;


/**
 * Indices
 */

Token.indexSet({
  params: 'accountId',
  key:    'accounts:$:apps',
  value:  'appId'
});


/**
 * Issue mapping
 */

Token.mappings.issue = {
  'access': 'access_token',
  'type': 'token_type',
  'scope': 'scope'
}


/**
 * Issue access token
 */

Token.issue = function (app, account, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }

  this.insert({
    appId: app._id,
    accountId: account._id,
    scope: options.scope
  }, function (err, token) {
    if (err) { return callback(err); }
    callback(null, token.project('issue'));
  })
};


/**
 * Verify access token
 */

Token.verify = function (access, scope, callback) {
  this.get(access, function (err, token) {
    if (!token) {
      return callback(new InvalidTokenError('Unknown access token'));
    }

    if (new Date() > token.expires_at) {
      return callback(new InvalidTokenError('Expired access token'));
    }

    if (token.scope.indexOf(scope) === -1) {
      return callback(new InsufficientScopeError());
    }

    callback(null, token);
  });
};


/**
 * Errors
 */

Token.InvalidTokenError = InvalidTokenError;
Token.InsufficientScopeError = InsufficientScopeError;


/**
 * Exports
 */

module.exports = Token;
