/**
 * Module dependencies
 */

var passport = require('passport')
  , User = require('../models/User');


module.exports = function (app) {

  /**
   * User registration endpoint
   */

  app.post('/account', function (req, res, next) {
    User.create(req.body, function (err, user) {
      if (err) { return next(err); }
      res.json(201, { authenticated: true, user: user.info });
    });
  });

};