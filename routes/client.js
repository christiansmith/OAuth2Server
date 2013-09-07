var passport = require('passport')
  , Client = require('../models/client');

module.exports = function (app) {

  var authenticate = app.authenticate;

  app.post('/clients', authenticate, function (req, res, next) {
    req.body.user_id = req.user._id;
    Client.create(req.body, function (err, client) {
      if (err) { return next(err); }
      res.json(201, client);
    });
  });

};