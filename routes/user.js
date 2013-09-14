/**
 * Module dependencies
 */

var cwd         = process.cwd()
  , path        = require('path')  
  , util        = require('util')
  , passport    = require('passport')
  , User        = require(path.join(cwd, 'models/User'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))    
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Local access token validation middleware
   */

  function authorize (req, res, next) {

    var headers = req.headers
      , authorization = headers['authorization'] || ''
      , access_token = authorization.replace(/^Bearer\s/, '')
      ;

    // fail if there is no access token in the Authorization header
    if (!access_token || access_token === '') { 
      return next(new InvalidRequestError('Missing access token')); 
    }

    AccessToken.verify(access_token, 'https://authorizationserver.tld', function (err, verified) {
      if (err && err.error === 'insufficient_scope') {
        next(new InsufficientScopeError());
      } else if (err) {
        next(new InvalidRequestError(err.description));
      } else {
        req.token = verified;
        next();        
      }

    });

  }

  /**
   * Access token specific user routes
   */

  app.get('/v1/user', authorize, function (req, res, next) {
    User.find({ _id: req.token.user_id }, function (err, user) {
      if (err) { return next(err); }
      res.json(user);
    });
  });


  app.post('/v1/user', authorize, function (req, res, next) {
    User.update({ _id: req.token.user_id }, req.body, function (err, user) {
      if (err) { return next(err); }
      res.json(user);
    });
  });


};


/**
 * InvalidRequestError
 */

function InvalidRequestError(description) {
  this.name = 'InvalidRequestError';
  this.message = 'invalid_request';
  this.description = description;
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InvalidRequestError, Error);


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

