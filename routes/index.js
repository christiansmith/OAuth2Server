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
   * RESTful routes
   */

  require('milonga')(app);   // adds app.resource

  var authenticate = passport.authenticate('basic', { 
    session: false 
  });

  app.resource('/v1/users',     User,     authenticate);
  app.resource('/v1/clients',   Client,   authenticate);
  app.resource('/v1/resources', Resource, authenticate);


  /**
   * OAuth 2.0 Routes
   */

  require('./oauth2')(app);


  /**
   * Protected resource routes (local)
   */

  app.get('/v1/user', function (req, res, next) {
    AccessToken.find({ access_token: req.query.access_token }, function (err, token) {
      if (err) { return next(err); }
      if (!token) { return next(new Error('AccessToken not found')); }
      User.find({ _id: token.user_id }, function (err, user) {
        if (err) { return next(err); }
        res.json(user);
      });
    });
  });

};