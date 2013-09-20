/**
 * Module dependencies
 */

var passport = require('passport')
  , Resource = require('../models/Resource')
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
   * GET /v1/resources
   */

  app.get('/v1/resources', authenticate, function (req, res, next) {
    Resource.find({}, function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/resources/:id
   */

  app.get('/v1/resources/:id', authenticate, function (req, res, next) {
    Resource.find({ _id: req.params.id }, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/resources
   */

  app.post('/v1/resources', authenticate, function (req, res, next) {
    Resource.create(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, instance);
    });
  });


  /**
   * PUT /v1/resources
   */

  app.put('/v1/resources/:id', authenticate, function (req, res, next) {
    var conditions = { _id: req.params.id }
      , attrs = req.body;

    Resource.update(conditions, attrs, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * DELETE /v1/resources/:id
   */

  app.del('/v1/resources/:id', authenticate, function (req, res, next) {
    Resource.destroy({ _id: req.params.id }, function (err) {
      if (err) { return next(err); }
      res.send(204);
    });
  });


};