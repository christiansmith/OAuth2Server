
/**
 * Module dependencies
 */

var passport      = require('passport')
  , Role           = require('../../models/Role')
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
   * GET /v1/roles
   */

  app.get('/v1/roles', authenticate, function (req, res, next) {
    Role.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);
    });
  });


  /**
   * GET /v1/roles/:id
   */

  app.get('/v1/roles/:id', authenticate, function (req, res, next) {
    Role.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/roles
   */

  app.post('/v1/roles', authenticate, function (req, res, next) {
    Role.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, instance);
    });
  });


  /**
   * PUT /v1/roles/:id
   */

  app.put('/v1/roles/:id', authenticate, function (req, res, next) {
    Role.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new Role(instance));
    });
  });


  /**
   * PATCH /v1/roles/:id
   */

  app.patch('/v1/roles/:id', authenticate, function (req, res, next) {
    Role.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/roles/:id
   */

  app.del('/v1/roles/:id', authenticate, function (req, res, next) {
    Role.delete(req.params.id, function (err, result) {
      if (err) { return next(err); }
      if (!result) { return next(new NotFoundError()); }
      res.send(204);
    });
  });

};
