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
    var url = new Buffer(req.params.id, 'base64').toString();
    Scope.get(url, function (err, instance) {
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
    var url = new Buffer(req.params.id, 'base64').toString();
    Scope.replace(url, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new Scope(instance));
    });
  });


  /**
   * PATCH /v1/scopes/:id
   */

  app.patch('/v1/scopes/:id', authenticate, function (req, res, next) {
    var url = new Buffer(req.params.id, 'base64').toString();
    Scope.patch(url, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/scopes/:id
   */

  app.del('/v1/scopes/:id', authenticate, function (req, res, next) {
    var url = new Buffer(req.params.id, 'base64').toString();
    Scope.delete(url, function (err, result) {
      if (err) { return next(err); }
      if (!result) { return next(new NotFoundError()); }
      res.send(204);
    });
  });

};
