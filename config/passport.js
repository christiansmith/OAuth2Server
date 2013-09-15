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

};