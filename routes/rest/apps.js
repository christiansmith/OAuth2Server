/**
 * Module dependencies
 */

var passport      = require('passport')
  , App           = require('../../models/App')
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
   * GET /v1/apps
   */

  app.get('/v1/apps', authenticate, function (req, res, next) {
    App.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/apps/:id
   */

  app.get('/v1/apps/:id', authenticate, function (req, res, next) {
    App.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/apps
   */

  app.post('/v1/apps', authenticate, function (req, res, next) {
    App.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, App.initialize(instance));
    });
  });


  /**
   * PUT /v1/apps/:id
   */

  app.put('/v1/apps/:id', authenticate, function (req, res, next) {
    App.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new App(instance));
    });
  });


  /**
   * PATCH /v1/apps/:id
   */

  app.patch('/v1/apps/:id', authenticate, function (req, res, next) {
    App.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/apps/:id
   */

  app.del('/v1/apps/:id', authenticate, function (req, res, next) {
    App.delete(req.params.id, function (err) {
      if (err) { return next(err); }
      res.send(204);
    });
  });

};
