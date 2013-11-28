/**
 * Module dependencies
 */

var passport      = require('passport')
  , Service       = require('../../models/Service')
  , NotFoundError = require('../../errors/NotFoundError')  
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
   * GET /v1/services
   */

  app.get('/v1/services', authenticate, function (req, res, next) {
    Service.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/services/:id
   */

  app.get('/v1/services/:id', authenticate, function (req, res, next) {
    Service.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/services
   */

  app.post('/v1/services', authenticate, function (req, res, next) {
    Service.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, Service.initialize(instance));
    });
  });


  /**
   * PUT /v1/services/:id
   */

  app.put('/v1/services/:id', authenticate, function (req, res, next) {
    Service.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new Service(instance));
    });
  });


  /**
   * PATCH /v1/services/:id
   */

  app.patch('/v1/services/:id', authenticate, function (req, res, next) {
    Service.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/services/:id
   */

  app.del('/v1/services/:id', authenticate, function (req, res, next) {
    Service.delete(req.params.id, function (err, result) {
      if (err) { return next(err); }
      if (!result) { return next(new NotFoundError()); }
      res.send(204);
    });
  });

};
