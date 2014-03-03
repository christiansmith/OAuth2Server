/**
 * Module dependencies
 */

var passport      = require('passport')
  , Group           = require('../../models/Group')
  , NotFoundError = require('../../errors/NotFoundError')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  /**
   * Authentication middleware
   */

  var authenticate = app.authenticate;


  /**
   * GET /v1/groups
   */

  app.get('/v1/groups', authenticate, function (req, res, next) {
    Group.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);
    });
  });


  /**
   * GET /v1/groups/:id
   */

  app.get('/v1/groups/:id', authenticate, function (req, res, next) {
    Group.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/groups
   */

  app.post('/v1/groups', authenticate, function (req, res, next) {
    Group.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, instance);
    });
  });


  /**
   * PUT /v1/groups/:id
   */

  app.put('/v1/groups/:id', authenticate, function (req, res, next) {
    Group.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(new Group(instance));
    });
  });


  /**
   * PATCH /v1/groups/:id
   */

  app.patch('/v1/groups/:id', authenticate, function (req, res, next) {
    Group.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/groups/:id
   */

  app.del('/v1/groups/:id', authenticate, function (req, res, next) {
    Group.delete(req.params.id, function (err, result) {
      if (err) { return next(err); }
      if (!result) { return next(new NotFoundError()); }
      res.send(204);
    });
  });

};
