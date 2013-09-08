/**
 * Module dependencies
 */

var cwd         = process.cwd()
  , path        = require('path')  
  , passport    = require('passport')

 // models
  , User        = require(path.join(cwd, 'models/User'))
  , Client      = require(path.join(cwd, 'models/Client'))
  , Resource    = require(path.join(cwd, 'models/Resource'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))    
  ;


module.exports = function (app) {

  /**
   * Resource definition helper
   */

  require('milonga')(app);


  /**
   * Authentication middleware
   */

  var authenticate = passport.authenticate('administration', { session: false });


  /**
   * RESTful routes
   */

  app.resource('/v1/users', User, authenticate);
  app.resource('/v1/clients', Client, authenticate);
  app.resource('/v1/resources', Resource, authenticate);


  /**
   * User info by access token
   */

  app.get('/api/user', function (req, res, next) {
    AccessToken.find({ access_token: req.query.access_token }, function (err, token) {
      if (err) { return next(err); }
      if (!token) { return next(new Error('AccessToken not found')); }
      User.find({ _id: token.user_id }, function (err, user) {
        if (err) { return next(err); }
        res.json(user.info);
      });
    });
  });

};