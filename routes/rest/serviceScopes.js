/**
 * Module dependencies
 */

var passport      = require('passport')
  , Service       = require('../../models/Service')
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

  var authenticate = app.authenticate;


  /**
   * GET /v1/services/:serviceId/scopes
   */

  app.get('/v1/services/:serviceId/scopes', authenticate,
    function (req, res, next) {

      // first, ensure the service exists
      Service.get(req.params.serviceId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list scopes by service
        Scope.listByServiceId(req.params.serviceId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/services/:serviceId/scopes/:scopeId
   */

  app.post('/v1/services/:serviceId/scopes', authenticate,
    function (req, res, next) {
      Service.get(req.params.serviceId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        var scope = new Scope(req.body);
        scope.serviceId = instance._id;

        Scope.insert(scope, function (err, instance) {
          if (err) { return next(err); }
          res.json(instance);
        });
      });
    });

};
