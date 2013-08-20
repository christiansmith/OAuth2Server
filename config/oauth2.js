/**
 * Module dependencies
 */

var oauth2 = require('oauth2orize')
  , passport = require('passport')
  , User = require('../models/User')
  , Client = require('../models/Client')
  , AccessToken = require('../models/AccessToken')  
  ;


module.exports = function (app) {
  var server = oauth2.createServer();

  server.exchange(oauth2.exchange.password(function(client, username, password, scope, done) {
    User.find({ 'info.email': username }, function (err, user) {
      if (err) { return done(err); }
      
      if (!user) { return done(null, false) }
      user.verifyPassword(password, function (err, verified) {
        if (err) { return done(err); }
      
        if (!verified) { return done(null, false); }
        AccessToken.issue(client, user, { scope: scope.join(' ') }, function (err, token) {
          if (err) { return done(err); }
      
          done(null, token.access_token, token.refresh_token);
        });
      })
    });
  }));

  app.post('/token', 
    passport.authenticate('basic', { session: false }), 
    server.token(),
    server.errorHandler());

};