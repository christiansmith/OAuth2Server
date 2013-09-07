/**
 * Module dependencies
 */

var LocalStrategy = require('passport-local').Strategy
  , BasicStrategy = require('passport-http').BasicStrategy
  , User     = require('../models/User')
  , Client   = require('../models/Client')
  , Resource = require('../models/Resource')  
  ;


/**
 * Exports
 */

module.exports = function (passport) {

  /**
   * Local Authentication
   */
  
  passport.use('local', new LocalStrategy({
    usernameField: 'email'
  }, function (email, password, done) {
    User.authenticate(email, password, function (err, user, info) {
      return done(err, user, info);
    });
  }));


  /**
   * Administration HTTP Basic Authentication Strategy
   */

  passport.use('administration', new BasicStrategy(function (id, secret, done) {
    if (id !== 'foo' || secret !== 'bar') {
      done(null, false);
    } else {
      done(null, true);
    }
  }));


  /**
   * Client HTTP Basic Authentication Strategy
   */

  passport.use('client', new BasicStrategy(function (username, password, done) {
    Client.find({ _id: username }, function (err, client) {
      if (!client || client.secret !== password) { return done(null, false) }
      return done(null, client);
    });
  }));


  /**
   * Resource Server HTTP Basic Authentication Strategy
   */

  passport.use('resource', new BasicStrategy(function (username, password, done) {
    Resource.find({ _id: username }, function (err, resource) {
      if (!resource || resource.secret !== password) { return done(null, false) }
      return done(null, resource);
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