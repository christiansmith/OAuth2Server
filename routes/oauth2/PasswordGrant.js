/**
 * Module dependencies
 */

var passport       = require('passport')
  , Account        = require('../../models/Account')
  , App            = require('../../models/App')  
  , Token          = require('../../models/Token')
  , AuthorizationError = require('../../errors/AuthorizationError')  
  ;


module.exports = function (app) {

  /**
   * Resource Owner Password Credentials Grant
   */

  var authenticateBasic = passport.authenticate('basic', { session: false });


  function missingUsername (req, res, next) {
    next((!req.body.username)
      ? new AuthorizationError('invalid_request', 'missing username parameter')
      : null);
  }

  function unknownUsername (req, res, next) {
    Account.getByEmail(req.body.username, function (err, account) {
      if (!account) { 
        next(new AuthorizationError('invalid_grant', 'invalid resource owner credentials'))
      } else {
        req.account = account;
        next()
      }
    });
  }

  function missingPassword (req, res, next) {
    next((!req.body.password)
      ? new AuthorizationError('invalid_request', 'missing password parameter')
      : null);
  }

  function mismatchingPassword (req, res, next) {
    req.account.verifyPassword(req.body.password, function (err, verified) {
      next((!verified)
        ? new AuthorizationError('invalid_grant', 'invalid resource owner credentials')
        : null);
    });
  }

  function lookupClient (req, res, next) {
    App.getByKey(req.user._id, function (err, application) {
      if (err) { return next(err); }
      req.client = application;
      next();
    });
  }

  /**
   * Token endpoint
   */

  app.post('/token', 
    authenticateBasic, 
    missingUsername,
    missingPassword,    
    unknownUsername,
    mismatchingPassword,
    lookupClient,
    function (req, res, next) {
      Token.issue(req.client, req.account, { scope: req.body.scope}, function (err, token) {
        if (err) { return next(err); }
        res.json(token);
      });
    });



};