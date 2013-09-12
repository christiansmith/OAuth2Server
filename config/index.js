/**
 * Configuration dependencies
 */

var express = require('express')
  , passport = require('passport') 
  , Modinha = require('modinha')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  app.configure(function () {

    // settings
    app.set('port', 3000);

    // request parsing
    app.use(express.cookieParser('secret'));
    app.use(express.bodyParser());
    
    // passport authentication middleware
    app.use(passport.initialize());
//    app.use(passport.session());

    // Explicitly register app.router
    // before error handling.
    app.use(app.router);

    // Error handler
    app.use(function (err, req, res, next) {   
      var error = (err.errors)
        ? { errors: err.errors }
        : { error: err.message, error_description: err.description };
      res.send(err.statusCode || 500, error);
    });

    Modinha.adapter = {
      type: 'modinha-json',
      path: 'data'
    };

  });

};