/**
 * Module dependencies
 */

var cwd      = process.cwd()
  , path     = require('path')  
  , passport = require('passport')
  , pkg      = require(path.join(cwd, 'package.json'))   
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Welcome
   */

  app.get('/', function (req, res) { 
    res.json({ "Welcome": "OAuth2Server v" + pkg.version }); 
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

};