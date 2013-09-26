/**
 * Module dependencies
 */

var passport = require('passport')
  , Client   = require('../models/Client')
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
   * GET /v1/clients
   */

  app.get('/v1/clients', authenticate, function (req, res, next) {
    Client.find({}, function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/clients/:id
   */

  app.get('/v1/clients/:id', authenticate, function (req, res, next) {
    Client.find({ _id: req.params.id }, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/clients
   */

  app.post('/v1/clients', authenticate, function (req, res, next) {
    Client.create(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, instance);
    });
  });


  /**
   * PUT /v1/clients
   */

  app.put('/v1/clients/:id', authenticate, function (req, res, next) {
    var conditions = { _id: req.params.id }
      , attrs = req.body;

    Client.update(conditions, attrs, function (err, instance) {
      console.log('UPDATED', err, instance)
      if (err) { return next(err); }
      res.json(instance);
    });
  });


  /**
   * DELETE /v1/clients/:id
   */

  app.del('/v1/clients/:id', authenticate, function (req, res, next) {
    Client.destroy({ _id: req.params.id }, function (err) {
      if (err) { return next(err); }
      res.send(204);
    });
  });


};