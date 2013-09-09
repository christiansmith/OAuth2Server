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

};