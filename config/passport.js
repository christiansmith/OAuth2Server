/**
 * Module dependencies
 */

var LocalStrategy = require('passport-local').Strategy
  , BasicStrategy = require('passport-http').BasicStrategy
  , User     = require('../models/User')
  , Client   = require('../models/Client')
  , Resource = require('../models/Resource') 
  , Credentials = require('../models/HTTPCredentials') 
  ;


/**
 * Exports
 */

module.exports = function (passport) {

  /**
   * HTTP Basic Authentication Strategy
   */

  passport.use('basic', new BasicStrategy(function (key, secret, done) {
    Credentials.find({ key: key }, function (err, credentials) {
      if (!credentials || credentials.secret !== secret) { return done(null, false) }
      return done(null, credentials);
    });
  }));


  /**
   * Password Login Stratety
   */

  passport.use(new LocalStrategy({ 
    usernameField: 'email' 
  }, function (email, password, done) {
    User.authenticate(email, password, function (err, user, info) {
      return done(err, user, info);
    });
  }));

  passport.serializeUser(function (user, done) {
    done(null, user._id);
  });

  passport.deserializeUser(function (id, done) {
    User.find({ _id: id }, function (err, user) {
      // https://github.com/jaredhanson/passport/issues/6#issuecomment-4857287
      // 
      // make sure `user` is null if not found
      // in order to invalidate the session.
      // This should be done at the persistence 
      // level. 
      if (user === undefined) { user = null; }
      done(err, user);
    });
  });

};