var express = require('express')
  , passport = require('passport')
  ;

module.exports = function (app) {

  app.configure(function () {
    app.set('port', 3000);
    app.use(express.bodyParser());
    
    // passport authentication middleware
    app.use(passport.initialize());
    app.use(passport.session());

    // Explicitly register app.router
    // before error handling.
    app.use(app.router);

    // Error handler
    app.use(function (err, req, res, next) {      
      var error = (err.errors)
        ? { errors: err.errors }
        : { error: err.message };
      res.send(err.statusCode || 500, error);
    });
  });

};