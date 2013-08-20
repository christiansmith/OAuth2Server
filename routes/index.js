var User = require('../models/User');

module.exports = function (app) {

  app.post('/account', function (req, res, next) {
    User.create(req.body, function (err, user) {
      if (err) { return next(err); }
      res.json(201, { authenticated: true, user: user.info });
    });
  });

};