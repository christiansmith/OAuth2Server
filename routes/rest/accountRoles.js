/**
 * Module dependencies
 */

var passport      = require('passport')
  , Account       = require('../../models/Account')
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
   * GET /v1/accounts/:accountId/roles
   */

  app.get('/v1/accounts/:accountId/roles', authenticate,
    function (req, res, next) {

      // first, ensure the account exists
      Account.get(req.params.accountId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list roles by account
        Role.listByAccounts(req.params.accountId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/accounts/:accountId/roles/:roleId
   */

  app.put('/v1/accounts/:accountId/roles/:roleId', authenticate,
    function (req, res, next) {
      Account.get(req.params.accountId, function (err, instance) {
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
   * DELETE /v1/accounts/:accountId/roles/:roleId
   */

  app.del('/v1/accounts/:accountId/roles/:roleId', authenticate,
    function (req, res, next) {
      Account.get(req.params.accountId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeRoles(req.params.roleId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
