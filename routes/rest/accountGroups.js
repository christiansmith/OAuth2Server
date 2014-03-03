/**
 * Module dependencies
 */

var passport      = require('passport')
  , Account       = require('../../models/Account')
  , Group         = require('../../models/Group')
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
   * GET /v1/accounts/:accountId/groups
   */

  app.get('/v1/accounts/:accountId/groups', authenticate,
    function (req, res, next) {

      // first, ensure the account exists
      Account.get(req.params.accountId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list groups by account
        Group.listByAccounts(req.params.accountId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/accounts/:accountId/groups/:groupId
   */

  app.put('/v1/accounts/:accountId/groups/:groupId', authenticate,
    function (req, res, next) {
      Account.get(req.params.accountId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        Group.get(req.params.groupId, function (err, group) {
          if (err) { return next(err); }
          if (!group) { return next(new NotFoundError()); }

          instance.addGroups(req.params.groupId, function (err, result) {
            if (err) { return next(err); }
            res.json({ added: true });
          });
        });
      });
    });


  /**
   * DELETE /v1/accounts/:accountId/groups/:groupId
   */

  app.del('/v1/accounts/:accountId/groups/:groupId', authenticate,
    function (req, res, next) {
      Account.get(req.params.accountId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeGroups(req.params.groupId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
