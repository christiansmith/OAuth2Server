/**
 * Module dependencies
 */

var path     = require('path')
  , passport = require('passport')
  , Account  = require('../models/Account')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Signin and signup routes
   */

  var ui = require('./ui')(app);

  app.get('/signin', ui);
  app.get('/signup', ui);
  app.get('/account', ui);


  /**
   * Password signup
   */

  app.post('/signup', function (req, res, next) {
    Account.insert(req.body, function (err, account) {
      if (err) { return next(err); }
      passport.authenticate('local', function (err, account, info) {
        req.login(account, function (err) {
          res.json(201, { authenticated: true, account: account });
        });
      })(req, res, next);
    });
  });


  /**
   * Password login
   */

  app.post('/login', function (req, res, next) {
    passport.authenticate('local', function (err, account, info) {
      if (!account) { return res.json(400, { error: info.message }); }
      req.login(account, function (err) {
        res.json({ authenticated: true, account: account });
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
      res.json({ authenticated: true,  account: req.user });
    } else {
      res.json({ authenticated: false });
    }
  });

};
