/**
 * Module dependencies
 */

var Model = require('./Model')
  , crypto = require('crypto')
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

AccessToken.prototype.verify = function (client_id, access_token, scope) {
  return client_id    === this.client_id 
      && access_token === this.access_token
      && new Date()   <   this.expires_at
      && scope        !== ''
      && this.scope.indexOf(scope) !== -1
      ;
};

//// untested draft of async verifiy, with custom errors
//AccessToken.verify = function (access_token, client_id, scope, callback) {
//  AccessToken.find({ access_token: access_token }, function (err, token) {
//    var invalid = !token 
//               || client_id    !== token.client_id
//               || access_token !== token.access_token
//               || new Date()   < token.expires_at
//                ;
//
//    if (invalid) { 
//      return callback(new InvalidTokenError()); 
//    }
//
//    if (token.scope.indexOf(scope) === -1) {
//      return callback(new InsufficientScopeError());
//    }
//
//    callback(null, true);
//  });
//};


/**
 * Exports
 */

module.exports = AccessToken;