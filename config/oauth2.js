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


  /**
   * Exchange user password credentials for an access token
   */

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


  /**
   * HTTP Basic authentication middleware
   */

  //var authenticate = app.authenticate = passport.authenticate('basic', { session: false });


  /**
   * Token endpoint
   */

  app.post('/token', 
    passport.authenticate('client', { session: false }), 
    server.token(),
    server.errorHandler());


  /**
   * Access token validation endpoint
   */

  app.post('/access', passport.authenticate('resource', { session: false }), function (req, res, next) {
    var token  = req.body.access_token
      , client = req.body.client_id
      , scope  = req.body.scope
      ;

    AccessToken.verify(token, client, scope, function (err, verified) {
      if (err) { return next(err); }
      res.json({ authorized: verified });
    });
  });

};