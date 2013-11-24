/**
 * Module dependencies
 */

var passport       = require('passport') 
  , Token          = require('../../models/Token')  
  ;


module.exports = function (app) {

  /**
   * Authentication middleware
   */

  var authenticateBasic = passport.authenticate('basic', { session: false });


  /**
   * Access token validation endpoint
   */

  app.post('/access', authenticateBasic, function (req, res, next) {
    var token  = req.body.access_token
      , scope  = req.body.scope
      ;

    Token.verify(token, scope, function (err, verified) {
      if (err) { return next(err); }
      res.json({ authorized: true });
    });
  });

};