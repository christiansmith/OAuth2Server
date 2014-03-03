/**
 * Module dependencies
 */

var passport      = require('passport')
  , Role       = require('../../models/Role')
  , Account         = require('../../models/Account')
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
   * GET /v1/roles/:roleId/accounts
   */

  app.get('/v1/roles/:roleId/accounts', authenticate,
    function (req, res, next) {

      // first, ensure the role exists
      Role.get(req.params.roleId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list accounts by role
        Account.listByRoles(req.params.roleId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/roles/:roleId/accounts/:accountId
   */

  app.put('/v1/roles/:roleId/accounts/:accountId', authenticate,
    function (req, res, next) {
      Role.get(req.params.roleId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        Account.get(req.params.accountId, function (err, account) {
          if (err) { return next(err); }
          if (!account) { return next(new NotFoundError()); }

          instance.addAccounts(req.params.accountId, function (err, result) {
            if (err) { return next(err); }
            res.json({ added: true });
          });
        });
      });
    });


  /**
   * DELETE /v1/roles/:roleId/accounts/:accountId
   */

  app.del('/v1/roles/:roleId/accounts/:accountId', authenticate,
    function (req, res, next) {
      Role.get(req.params.roleId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeAccounts(req.params.accountId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
