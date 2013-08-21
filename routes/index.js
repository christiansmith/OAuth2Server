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

  /**
   * User authentication endpoint
   */
  
  app.post('/login', function (req, res, next) {
    passport.authenticate('local', function (err, user, info) {
      if (!user) { return res.json(400, { error: info.message }); }
      req.login(user, function (err) {
        res.json({ authenticated: true, user: user.info });
      });
    })(req, res, next);
  });

  /**
   * User logout endpoint
   */

  app.post('/logout', function (req, res) {
    req.logout();
    res.send(204);
  });


  /**
   * User session endpoint
   */

  app.get('/session', function (req, res) {
    if (req.user) {
      res.json({ authenticated: true,  user: req.user.info });
    } else {
      res.json({ authenticated: false });
    }
  });

};