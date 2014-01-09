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
    var access_token  = req.body.access_token
      , scope  = req.body.scope
      ;

    Token.verify(access_token, scope, function (err, token) {
      if (err) { return next(err); }
      res.json({
        authorized: true,
        account_id: token.accountId
      });
    });
  });

};
