/**
 * Module dependencies
 */

var util           = require('util')
  , oauth2         = require('oauth2orize')
  , passport       = require('passport')
  , User           = require('../models/User')
  , Client         = require('../models/Client')
  , Scope          = require('../models/Scope')   
  , AccessToken    = require('../models/AccessToken')  
  , FormUrlencoded = require('form-urlencoded')
  ;


module.exports = function (app) {
  var server = oauth2.createServer();


  /**
   * Exchange user password credentials for an access token
   */

  server.exchange(oauth2.exchange.password(function(client, email, password, scope, done) {
    User.find({ email: email }, { private: true }, function (err, user) {
      if (err) { return done(err); }
      
      if (!user) { return done(null, false) }
      user.verifyPassword(password, function (err, verified) {
        if (err) { return done(err); }
      
        if (!verified) { return done(null, false); }
        AccessToken.issue(client, user, { scope: scope.join(' ') }, function (err, token) {
          if (err) { return done(err); }
      
          done(null, token.access_token, token.refresh_token);
        });
      })
    });
  }));


  server.grant(oauth2.grant.token(function(client, user, ares, done) {
    AccessToken.issue(client, user, { scope: ares.scope }, function(err, accessToken) {
      if (err) { return done(err); }
      done(null, accessToken);
    });
  }));


  /**
   * Authentication middleware
   */

  var authenticate = passport.authenticate('basic', { session: false });


  /**
   * Token endpoint
   */

  app.post('/token', 
    authenticate, 
    server.token(),
    server.errorHandler());


  /**
   * Access token validation endpoint
   */

  app.post('/access', authenticate, function (req, res, next) {
    var token  = req.body.access_token
      , scope  = req.body.scope
      ;

    AccessToken.verify(token, scope, function (err, verified) {
      if (err) { return next(err); }
      res.json({ authorized: true });
    });
  });




  /**
   * Authorization UI
   */

  var ui = require('./ui')(app);


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
    Client.find({ _id: req[methodObject[req.method]].client_id }, function (err, client) {
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
        client: req.client, 
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
    //server.token(),
    //server.errorHandler(), 
    function (req, res, next) {
      if (req.body.authorized) {
        AccessToken.issue(req.client, req.user, { scope: '' }, function (err, token) {
          if (err) { return next(err); }
          res.redirect(req.body.redirect_uri + '#' + FormUrlencoded.encode(token));
        });

        
      } else {
        res.redirect(req.body.redirect_uri + '#error=access_denied');
      }
      
    });


  /**
   * AuthorizationError
   */

  function AuthorizationError(message, description, status) {
    this.name = 'AuthorizationError';
    this.message = message || 'invalid_request';
    this.description = description;
    this.statusCode = status || 400;
    Error.call(this, this.message);
    Error.captureStackTrace(this, arguments.callee);
  }

  util.inherits(AuthorizationError, Error);

};