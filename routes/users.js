/**
 * Module dependencies
 */

var cwd      = process.cwd()
  , path     = require('path')  
  , passport = require('passport')
  , User     = require(path.join(cwd, 'models/User'))
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Authentication middleware
   */

  var authenticate = passport.authenticate('basic', { 
    session: false 
  });
  

  /**
   * GET /v1/users
   */

  app.get('/v1/users', authenticate, function (req, res, next) {
    User.find({}, function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/users/:id
   */

  app.get('/v1/users/:id', authenticate, function (req, res, next) {
    User.find({ _id: req.params.id }, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/users
   */

  app.post('/v1/users', authenticate, function (req, res, next) {
    User.create(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, new User(instance));
    });
  });


  /**
   * PUT /v1/users
   */

  app.put('/v1/users/:id', authenticate, function (req, res, next) {
    var conditions = { _id: req.params.id }
      , attrs = req.body;

    User.update(conditions, attrs, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * DELETE /v1/users/:id
   */

  app.del('/v1/users/:id', authenticate, function (req, res, next) {
    User.destroy({ _id: req.params.id }, function (err) {
      if (err) { return next(err); }
      res.send(204);
    });
  });


};