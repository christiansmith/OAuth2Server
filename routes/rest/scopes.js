/**
 * Module dependencies
 */

var passport      = require('passport')
  , Scope         = require('../../models/Scope')
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
   * GET /v1/scopes
   */

  app.get('/v1/scopes', authenticate, function (req, res, next) {
    Scope.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);        
    });
  });


  /**
   * GET /v1/scopes/:id
   */

  app.get('/v1/scopes/:id', authenticate, function (req, res, next) {
    Scope.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/scopes
   */

  app.post('/v1/scopes', authenticate, function (req, res, next) {
    Scope.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, Scope.initialize(instance));
    });
  });


  /**
   * PUT /v1/scopes/:id
   */

  app.put('/v1/scopes/:id', authenticate, function (req, res, next) {
    Scope.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new Scope(instance));
    });
  });


  /**
   * PATCH /v1/scopes/:id
   */

  app.patch('/v1/scopes/:id', authenticate, function (req, res, next) {
    Scope.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/scopes/:id
   */

  app.del('/v1/scopes/:id', authenticate, function (req, res, next) {
    Scope.delete(req.params.id, function (err) {
      if (err) { return next(err); }
      res.send(204);
    });
  });

};
