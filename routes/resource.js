var Resource = require('../models/Resource');

module.exports = function (app) {

  app.post('/resources', app.authenticate, function (req, res, next) {
    req.body.user_id = req.user._id;
    Resource.create(req.body, function (err, resource) {
      if (err) { return next(err); }
      res.json(201, resource);
    });
  });

};