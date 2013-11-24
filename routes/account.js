/**
 * Module dependencies
 */

var cwd         = process.cwd()
  , path        = require('path')  
  , passport    = require('passport')
  , Account     = require('../models/Account')
  , Token       = require('../models/Token')
  , InvalidRequestError = require('../errors/InvalidRequestError')
  , InvalidTokenError = require('../errors/InvalidTokenError')
  , InsufficientScopeError = require('../errors/InsufficientScopeError')    
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

    Token.verify(access_token, 'https://authorizationserver.tld', function (err, verified) {
      if (err && err.message === 'insufficient_scope') {
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
   * Access token specific account routes
   */

  app.get('/v1/account', authorize, function (req, res, next) {
    Account.get(req.token.accountId, function (err, account) {
      if (err) { return next(err); }
      res.json(account);
    });
  });


  app.patch('/v1/account', authorize, function (req, res, next) {
    Account.patch(req.token.accountId, req.body, function (err, account) {
      if (err) { return next(err); }
      res.json(account);
    });
  });


};

