/**
 * Module dependencies
 */

var passport      = require('passport')
  , App       = require('../../models/App')
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
   * GET /v1/apps/:appId/groups
   */

  app.get('/v1/apps/:appId/groups', authenticate,
    function (req, res, next) {

      // first, ensure the app exists
      App.get(req.params.appId, function (err, instance) {
        if (err) { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        // then list groups by app
        Group.listByApps(req.params.appId, function (err, instances) {
          if (err) { return next(err); }
          res.json(instances);
        });
      });
    });


  /**
   * PUT /v1/apps/:appId/groups/:groupId
   */

  app.put('/v1/apps/:appId/groups/:groupId', authenticate,
    function (req, res, next) {
      App.get(req.params.appId, function (err, instance) {
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
   * DELETE /v1/apps/:appId/groups/:groupId
   */

  app.del('/v1/apps/:appId/groups/:groupId', authenticate,
    function (req, res, next) {
      App.get(req.params.appId, function (err, instance) {
        if (err)       { return next(err); }
        if (!instance) { return next(new NotFoundError()); }

        instance.removeGroups(req.params.groupId, function (err, result) {
          if (err) { return next(err); }
          res.send(204);
        });
      });
    });

};
