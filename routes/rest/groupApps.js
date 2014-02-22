/**
 * Module dependencies
 */

var passport = require('passport')
  , Group    = require('../../models/Group')
  , App      = require('../../models/App')
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
   * GET /v1/groups/:groupId/apps
   */

  app.get('/v1/groups/:groupId/apps', authenticate,
    function (req, res, next) {

      // first, ensure the group exists
      Group.get(req.params.groupId, function (err, group) {
        if (err) { return next(err); }
        if (!group) { return next(new NotFoundError()); }

        // then list apps by group
        App.listByGroups(req.params.groupId, function (err, apps) {
          if (err) { return next(err); }
          res.json(apps);
        });
      });
    });


  /**
   * PUT /v1/groups/:groupId/apps/:appId
   */

  app.put('/v1/groups/:groupId/apps/:appId', authenticate,
    function (req, res, next) {
      Group.get(req.params.groupId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        App.get(req.params.appId, function (err, app) {
          if (err) { return next(err); }
          if (!app) { return next(new NotFoundError()); }

          instance.addApps(req.params.appId, function (err, result) {
            if (err) { return next(err); }
            res.json({ added: true });
          });
        });
      });
    });


  /**
   * DELETE /v1/groups/:groupId/apps/:appId
   */

  app.del('/v1/groups/:groupId/apps/:appId', authenticate,
    function (req, res, next) {
      Group.get(req.params.groupId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeApps(req.params.appId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
