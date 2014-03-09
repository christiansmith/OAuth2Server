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

  var authenticateUser = app.authenticateUser;


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


  /**
   * Validate authorization params
   */

  var validateRequest = [
    missingClient,
    unknownClient,
    missingResponseType,
    unsupportedResponseType,
    missingRedirectURI,
    mismatchingRedirectURI,
  ];


  /**
   * Get scope details for authorize view
   */

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
   * Issue Access Token
   */

  function issueToken (req, res, next) {
    if (req.body.authorized) {
      Token.issue(req.client, req.user, { scope: req.body.scope }, function (err, token) {
        req.token = token;
        next(err);
      })
    } else {
      next();
    }
  }


  /**
   * Redirect to client app
   */

  function redirectToClient (req, res, next) {
    if (req.token && req.isAuthenticated()) {
      var redirect_uri = req[methodObject[req.method]].redirect_uri + '#' + FormUrlencoded.encode(req.token);
      if (req.is('json') && req.method === 'GET') {
        res.json({ redirect_uri: redirect_uri });
      } else {
        res.redirect(redirect_uri);
      }
    } else if (req.body.authorized === false) {
      res.redirect(req.body.redirect_uri + '#error=access_denied');
    } else {
      next();
    }
  }


  /**
   * Verify Group Membership
   */

  function verifyGroupMembership (req, res, next) {
    req.user.isAppGroupsMember(req.client, function (err, member) {
      if (err) { return next(err); }
      if (!member) {
        var error = new Error();
        error.statusCode = 403;
        error.message = 'unauthorized_user'
        error.description = 'Unauthorized user'
        next(error);
      } else {
        next();
      }
    });
  }


  /**
   * Find existing access token
   */

  function findExistingToken (req, res, next) {
    if (req.isAuthenticated() && req.query.client_id) {
      Token.existing(req.user._id, req.query.client_id, function (err, token) {
        req.token = token;
        next(err || null);
      });
    } else {
      next();
    }
  }


  /**
   * GET /authorize
   */

  app.get('/authorize',
    findExistingToken,
    redirectToClient,
    ui,
    authenticateUser,
    validateRequest,
    verifyGroupMembership,
    scopeDetails,
    function (req, res, next) {
      res.json({
        app: req.client,
        scope: req.scope
      });
    });


  /**
   * POST /authorize
   */

  app.post('/authorize',
    authenticateUser,
    validateRequest,
    verifyGroupMembership,
    issueToken,
    redirectToClient
  );

};




