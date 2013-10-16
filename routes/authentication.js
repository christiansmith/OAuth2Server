/**
 * Module dependencies
 */

var path = require('path')
  , passport = require('passport')
  , User     = require('../models/User')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * User interface app
   *
   * We assume this is a single page app 
   * and that front-end routing with show the 
   * correct view.
   */

  var ui = function (req, res) {
    res.sendfile('index.html', { 
      root: app.settings['local-ui']
    });
  }

  app.get('/authorize', ui);
  app.get('/signin', ui);
  app.get('/signup', ui);


  /**
   * Password signup
   */

  app.post('/signup', function (req, res, next) {
    User.create(req.body, function (err, user) {
      if (err) { return next(err); }
      passport.authenticate('local', function (err, user, info) {
        req.login(user, function (err) {
          res.json(201, { authenticated: true, user: user });
        });
      })(req, res, next);
    });
  });


  /**
   * Password login
   */

  app.post('/login', function (req, res, next) {
    passport.authenticate('local', function (err, user, info) {
      if (!user) { return res.json(400, { error: info.message }); }
      req.login(user, function (err) {
        res.json({ authenticated: true, user: user });
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
      res.json({ authenticated: true,  user: req.user });
    } else {
      res.json({ authenticated: false });
    }
  });

};
