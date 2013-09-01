var cwd = process.cwd()
  , path = require('path')  
  , User = require(path.join(cwd, 'models/User')) 
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))   
  ;

module.exports = function (app) {

  app.get('/api/user', function (req, res, next) {
    AccessToken.find({ access_token: req.query.access_token }, function (err, token) {
      if (err) { return next(err); }
      if (!token) { return next(new Error('AccessToken not found')); }
      User.find({ _id: token.user_id }, function (err, user) {
        if (err) { return next(err); }
        res.json(user.info);
      });
    });
  });

};