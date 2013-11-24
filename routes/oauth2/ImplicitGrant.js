/**
 * Module dependencies
 */

var App            = require('../../models/App')
  , Scope          = require('../../models/Scope')   
  , Token          = require('../../models/Token')  
  , FormUrlencoded = require('form-urlencoded')
  , AuthorizationError = require('../../errors/AuthorizationError')  
  ;


module.exports = function (app) {

  /**
   * Authorization UI
   */

  var ui = require('../ui')(app);

  /**
   * Parameter lookup helper
   */

  var methodObject = { 'POST': 'body', 'GET': 'query'}


  /**
   * Local user authentication middleware
   */

  function authenticateUser (req, res, next) {
    if (req.isAuthenticated()) { return next(); }
    res.send(401, 'Unauthorized');
  };


  /**
   * Implicit Grant Middleware
   */

  function missingClient (req, res, next) {
    next((!req[methodObject[req.method]].client_id)
      ? new AuthorizationError('unauthorized_client', 'Missing client id', 403)
      : null); 
  };

  function unknownClient (req, res, next) {
    App.get(req[methodObject[req.method]].client_id, function (err, client) {
      if (!client) { 
        next(new AuthorizationError('unauthorized_client', 'Unknown client', 403)); 
      } else {
        req.client = client;
        next();
      }
    });
  };

  function missingResponseType (req, res, next) {
    next((!req[methodObject[req.method]].response_type)
      ? new AuthorizationError('invalid_request', 'Missing response type', 501)
      : null);
  };

  function unsupportedResponseType (req, res, next) {
    next((req[methodObject[req.method]].response_type !== 'token')
      ? new AuthorizationError('unsupported_response_type', 'Unsupported response type', 501)
      : null);
  };

  function missingRedirectURI (req, res, next) {
    next((!req[methodObject[req.method]].redirect_uri)
      ? new AuthorizationError('invalid_request', 'Missing redirect uri')
      : null);
  };

  function mismatchingRedirectURI (req, res, next) {
    next((req.client.redirect_uri !== req[methodObject[req.method]].redirect_uri)
      ? new AuthorizationError('invalid_request', 'Mismatching redirect uri')
      : null);
  }

  function scopeDetails (req, res, next) {
    var scope = (req.query.scope)
              ? req.query.scope.split(' ')
              : [];

    if (scope.length > 0) {
      Scope.get(scope, function (err, result) {
        if (err) { return next(err); }
        req.scope = result;
        next();
      });
    } else {
      req.scope = [];
      next();
    }
  }

  /**
   * Authorize endpoints
   */

  app.get('/authorize', 
    ui, 
    missingClient, 
    unknownClient,
    missingResponseType, 
    unsupportedResponseType,
    missingRedirectURI,
    mismatchingRedirectURI,
    scopeDetails,
    function (req, res, next) {
      res.json({ 
        app: req.client, 
        scope: req.scope
      });
    });
  
  app.post('/authorize', 
    authenticateUser, 
    missingClient,     
    unknownClient,
    missingResponseType,
    unsupportedResponseType,
    missingRedirectURI,
    mismatchingRedirectURI,  
    function (req, res, next) {
      if (req.body.authorized) {
        Token.issue(req.client, req.user, { scope: '' }, function (err, token) {
          if (err) { return next(err); }
          res.redirect(req.body.redirect_uri + '#' + FormUrlencoded.encode(token));
        }); 
      } else {
        res.redirect(req.body.redirect_uri + '#error=access_denied');
      }
    });

};