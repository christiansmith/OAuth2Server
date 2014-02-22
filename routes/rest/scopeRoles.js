/**
 * Module dependencies
 */

var passport      = require('passport')
  , Scope       = require('../../models/Scope')
  , Role         = require('../../models/Role')
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
   * GET /v1/scopes/:scopeId/roles
   */

  app.get('/v1/scopes/:scopeId/roles', authenticate,
    function (req, res, next) {

      // first, ensure the scope exists
      Scope.get(req.params.scopeId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list roles by scope
        Role.listByScopes(req.params.scopeId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/scopes/:scopeId/roles/:roleId
   */

  app.put('/v1/scopes/:scopeId/roles/:roleId', authenticate,
    function (req, res, next) {
      Scope.get(req.params.scopeId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        Role.get(req.params.roleId, function (err, role) {
          if (err) { return next(err); }
          if (!role) { return next(new NotFoundError()); }

          instance.addRoles(req.params.roleId, function (err, result) {
            if (err) { return next(err); }
            res.json({ added: true });
          });
        });
      });
    });


  /**
   * DELETE /v1/scopes/:scopeId/roles/:roleId
   */

  app.del('/v1/scopes/:scopeId/roles/:roleId', authenticate,
    function (req, res, next) {
      Scope.get(req.params.scopeId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeRoles(req.params.roleId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
