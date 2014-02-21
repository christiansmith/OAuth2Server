/**
 * Module dependencies
 */

var passport      = require('passport')
  , Role       = require('../../models/Role')
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
   * GET /v1/roles/:roleId/scopes
   */

  app.get('/v1/roles/:roleId/scopes', authenticate,
    function (req, res, next) {

      // first, ensure the role exists
      Role.get(req.params.roleId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list scopes by role
        Scope.listByRoles(req.params.roleId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/roles/:roleId/scopes/:scopeId
   */

  app.put('/v1/roles/:roleId/scopes/:scopeId', authenticate,
    function (req, res, next) {
      Role.get(req.params.roleId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        Scope.get(req.params.scopeId, function (err, scope) {
          if (err) { return next(err); }
          if (!scope) { return next(new NotFoundError()); }

          instance.addScopes(req.params.scopeId, function (err, result) {
            if (err) { return next(err); }
            res.json({ added: true });
          });
        });
      });
    });


  /**
   * DELETE /v1/roles/:roleId/scopes/:scopeId
   */

  app.del('/v1/roles/:roleId/scopes/:scopeId', authenticate,
    function (req, res, next) {
      Role.get(req.params.roleId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeScopes(req.params.scopeId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
