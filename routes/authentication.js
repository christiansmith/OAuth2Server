/**
 * Module dependencies
 */

var path     = require('path')
  , util     = require('util')
  , passport = require('passport')
  , User     = require('../models/User')
  , Client   = require('../models/Client')  
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * User interface app
   *
   * We assume this is a single page app 
   * and that front-end routing with show the 
   * correct view.
   */

  function ui (req, res, next) {
    if (req.is('json')) {
      next();
    } else {
      res.sendfile('index.html', { 
        root: app.settings['local-ui']
      });
    } 
  };

  function missingClient (req, res, next) {
    next((!req.query.client_id)
      ? new AuthorizationError('unauthorized_client', 'Missing client id', 403)
      : null); 
  };

  function unknownClient (req, res, next) {
    Client.find({ _id: req.query.client_id }, function (err, client) {
      if (!client) { 
        next(new AuthorizationError('unauthorized_client', 'Unknown client', 403)); 
      } else {
        req.client = client;
        next();
      }
    });
  };

  function missingResponseType (req, res, next) {
    next((!req.query.response_type)
      ? new AuthorizationError('invalid_request', 'Missing response type', 501)
      : null);
  };

  function unsupportedResponseType (req, res, next) {
    next((req.query.response_type !== 'token')
      ? new AuthorizationError('unsupported_response_type', 'Unsupported response type', 501)
      : null);
  };

  function missingRedirectURI (req, res, next) {
    next((!req.query.redirect_uri)
      ? new AuthorizationError('invalid_request', 'Missing redirect uri')
      : null);
  };

  function mismatchingRedirectURI (req, res, next) {
    next((req.client.redirect_uri !== req.query.redirect_uri)
      ? new AuthorizationError('invalid_request', 'Mismatching redirect uri')
      : null);
  }

  app.get('/authorize', 
    ui, 
    missingClient, 
    unknownClient,
    missingResponseType, 
    unsupportedResponseType,
    missingRedirectURI,
    mismatchingRedirectURI,
    function (req, res, next) {
      res.json({ scope: [] });
    });

  app.get('/signin', ui);
  app.get('/signup', ui);


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


  /**
   * Password signup
   */

  app.post('/signup', function (req, res, next) {
    User.create(req.body, function (err, user) {
      if (err) { return next(err); }
      passport.authenticate('local', function (err, user, info) {
        req.login(user, function (err) {
          res.json(201, { authenticated: true, user: user });
        });
      })(req, res, next);
    });
  });


  /**
   * Password login
   */

  app.post('/login', function (req, res, next) {
    passport.authenticate('local', function (err, user, info) {
      if (!user) { return res.json(400, { error: info.message }); }
      req.login(user, function (err) {
        res.json({ authenticated: true, user: user });
      });
    })(req, res, next);
  });


  /**
   * Logout
   */

  app.post('/logout', function (req, res) {
    req.logout();
    res.send(204);
  });


  /**
   * Session
   */

  app.get('/session', function (req, res) {
    if (req.user) {
      res.json({ authenticated: true,  user: req.user });
    } else {
      res.json({ authenticated: false });
    }
  });

};
