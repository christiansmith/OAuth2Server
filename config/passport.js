/**
 * Module dependencies
 */

var BasicStrategy = require('passport-http').BasicStrategy
  , User = require('../models/User')
  , Client = require('../models/Client')
  ;


/**
 * Exports
 */

module.exports = function (passport) {


  /**
   * Basic Strategy
   */

  passport.use('basic', new BasicStrategy(function (username, password, done) {
    Client.find({ _id: username }, function (err, client) {
      if (!client || client.secret !== password) { return done(null, false) }
      return done(null, client);
    });
  }));

};