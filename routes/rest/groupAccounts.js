
/**
 * Module dependencies
 */

var passport      = require('passport')
  , Group       = require('../../models/Group')
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

  var authenticate = passport.authenticate('basic', {
    session: false
  });


  /**
   * GET /v1/groups/:groupId/accounts
   */

  app.get('/v1/groups/:groupId/accounts', authenticate,
    function (req, res, next) {

      // first, ensure the group exists
      Group.get(req.params.groupId, function (err, group) {
        if (err) { return next(err); }
        if (!group) { return next(new NotFoundError()); }

        // then list accounts by group
        Account.listByGroups(req.params.groupId, function (err, accounts) {
          if (err) { return next(err); }
          res.json(accounts);
        });
      });
    });


  /**
   * PUT /v1/groups/:groupId/accounts/:accountId
   */

  app.put('/v1/groups/:groupId/accounts/:accountId', authenticate,
    function (req, res, next) {
      Group.get(req.params.groupId, function (err, instance) {
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
   * DELETE /v1/groups/:groupId/accounts/:accountId
   */

  app.del('/v1/groups/:groupId/accounts/:accountId', authenticate,
    function (req, res, next) {
      Group.get(req.params.groupId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeAccounts(req.params.accountId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
