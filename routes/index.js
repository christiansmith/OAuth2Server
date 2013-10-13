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
   * Authentication middleware
   */

  app.authenticate = passport.authenticate('basic', { 
    session: false 
  });

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

  require('./users')(app);
  require('./clients')(app);
  require('./resources')(app);


  /**
   * OAuth 2.0 Routes
   */

  require('./oauth2')(app);


  /**
   * Protected resource routes (user)
   */

  require('./user')(app);


  /**
   * Authentication routes
   */
  
  if (app.settings['local-ui'] !== false) {
    require('./authentication')(app);
  }
  //if (config['local-ui'] !== false) {
  //  require('./authentication')(app);
  //}
  

};