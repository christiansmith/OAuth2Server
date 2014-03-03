/**
 * Module dependencies
 */

var passport      = require('passport')
  , Account       = require('../../models/Account')
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
   * GET /v1/accounts
   */

  app.get('/v1/accounts', authenticate, function (req, res, next) {
    Account.list(function (err, instances) {
      if (err) { return next(err); }
      res.json(instances);
    });
  });


  /**
   * GET /v1/accounts/:id
   */

  app.get('/v1/accounts/:id', authenticate, function (req, res, next) {
    Account.get(req.params.id, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * POST /v1/accounts
   */

  app.post('/v1/accounts', authenticate, function (req, res, next) {
    Account.insert(req.body, function (err, instance) {
      if (err) { return next(err); }
      res.json(201, instance);
    });
  });


  /**
   * PUT /v1/accounts/:id
   */

  app.put('/v1/accounts/:id', authenticate, function (req, res, next) {
    Account.replace(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance);
    });
  });


  /**
   * PATCH /v1/accounts/:id
   */

  app.patch('/v1/accounts/:id', authenticate, function (req, res, next) {
    Account.patch(req.params.id, req.body, function (err, instance) {
      if (err) { return next(err); }
      if (!instance) { return next(new NotFoundError()); }
      res.json(instance)
    });
  });


  /**
   * DELETE /v1/accounts/:id
   */

  app.del('/v1/accounts/:id', authenticate, function (req, res, next) {
    Account.delete(req.params.id, function (err, result) {
      if (err) { return next(err); }
      if (!result) { return next(new NotFoundError()); }
      res.send(204);
    });
  });

};
