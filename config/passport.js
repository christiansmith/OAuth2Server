/**
 * Module dependencies
 */

var LocalStrategy = require('passport-local').Strategy
  , BasicStrategy = require('passport-http').BasicStrategy
  , Account       = require('../models/Account')
  , Credentials   = require('../models/Credentials')
  ;


/**
 * Exports
 */

module.exports = function (passport) {

  /**
   * HTTP Basic Authentication Strategy
   */

  passport.use('basic', new BasicStrategy(function (key, secret, done) {
    Credentials.get(key, function (err, credentials) {
      if (!credentials || credentials.secret !== secret) { return done(null, false) }
      return done(null, credentials);
    });
  }));


  /**
   * Password Login Stratety
   */

  passport.use('local', new LocalStrategy({
    usernameField: 'email'
  }, function (email, password, done) {
    Account.authenticate(email, password, function (err, account, info) {
      return done(err, account, info);
    });
  }));

  passport.serializeUser(function (account, done) {
    done(null, account._id);
  });

  passport.deserializeUser(function (id, done) {
    Account.get(id, function (err, account) {
      done(err, account);
    });
  });

};
