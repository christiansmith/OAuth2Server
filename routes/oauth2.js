/**
 * Module dependencies
 */

var cwd         = process.cwd()
  , path        = require('path')
  , oauth2      = require('oauth2orize')
  , passport    = require('passport')
  , User        = require(path.join(cwd, 'models/User'))
  , Client      = require(path.join(cwd, 'models/Client'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))  
  ;


module.exports = function (app) {
  var server = oauth2.createServer();


  /**
   * Exchange user password credentials for an access token
   */

  server.exchange(oauth2.exchange.password(function(client, email, password, scope, done) {
    User.find({ email: email }, { private: true }, function (err, user) {
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
   * Authentication middleware
   */

  var authenticate = passport.authenticate('basic', { session: false });


  /**
   * Token endpoint
   */

  app.post('/token', 
    authenticate, 
    server.token(),
    server.errorHandler());


  /**
   * Access token validation endpoint
   */

  app.post('/access', authenticate, function (req, res, next) {
    var token  = req.body.access_token
      , scope  = req.body.scope
      ;

    AccessToken.verify(token, scope, function (err, verified) {
      if (err) { return next(err); }
      res.json({ authorized: true });
    });
  });

};