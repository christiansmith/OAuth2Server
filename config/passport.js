/**
 * Module dependencies
 */

var LocalStrategy = require('passport-local').Strategy
  , BasicStrategy = require('passport-http').BasicStrategy
  , User = require('../models/User')
  , Client = require('../models/Client')
  ;


/**
 * Exports
 */

module.exports = function (passport) {

  /**
   * Local Authentication
   */
  
  passport.use(new LocalStrategy({
    usernameField: 'email'
  }, function (email, password, done) {
    User.authenticate(email, password, function (err, user, info) {
      return done(err, user, info);
    });
  }));


  /**
   * HTTP Basic Authentication Strategy
   */

  passport.use('basic', new BasicStrategy(function (username, password, done) {
    Client.find({ _id: username }, function (err, client) {
      if (!client || client.secret !== password) { return done(null, false) }
      return done(null, client);
    });
  }));


  /**
   * User session
   */

  passport.serializeUser(function (user, done) {
    done(null, user._id);
  });

  passport.deserializeUser(function (id, done) {
    User.find({ _id: id }, function (err, user) {
      done(err, user);
    });
  });

};