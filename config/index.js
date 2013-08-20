var express = require('express');

module.exports = function (app) {

  app.configure(function () {
    app.set('port', 3000);
    app.use(express.bodyParser());
    
    // Explicitly register router
    // before error handler.
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