/**
 * Module dependencies
 */

var cwd      = process.cwd()
  , path     = require('path')
  , passport = require('passport')
  , pkg      = require('../package.json')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Basic authentication middleware
   */

  app.authenticate = passport.authenticate('basic', {
    session: false
  });


  /**
   * Local user authentication middleware
   */

  app.authenticateUser = function authenticateUser (req, res, next) {
    if (req.isAuthenticated()) { return next(); }
    res.send(401, 'Unauthorized');
  };


  /**
   * Welcome
   */

  app.get('/', function (req, res) {
    res.json({ "Welcome": "OAuth2Server v" + pkg.version });
  });


  /**
   * Verify HTTP Basic Credentials
   */

  app.post('/', app.authenticate, function (req, res) {
    res.json({ validCredentials: true });
  });


  /**
   * RESTful routes
   */

  require('./rest/accounts')(app);
  require('./rest/apps')(app);
  require('./rest/services')(app);
  require('./rest/scopes')(app);


  /**
   * OAuth 2.0 Routes
   */

  require('./oauth2/PasswordGrant')(app);
  require('./oauth2/ImplicitGrant')(app);
  require('./oauth2/ValidateToken')(app);


  /**
   * Protected resource routes (account)
   */

  require('./account')(app);


  /**
   * Authentication routes
   */

  if (app.settings['local-ui'] !== false) {
    require('./authentication')(app);
  }

};
