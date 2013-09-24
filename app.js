/**
 * App dependencies
 */

var express = require('express')
  , passport = require('passport')
  , app = express()
  ;


/**
 * Configuration and routes
 */

require('./config/')(app);
require('./config/passport')(passport);
require('./routes/')(app);


/**
 * Start the server
 */

app.start = function () {
  app.listen(app.settings.port, function () {
    console.log(
        'OAuth2Server is running on port ' + app.settings.port
    );   
  });
}


/**
 * Exports
 */

module.exports = app;


/**
 * Start the server in shell from development directory
 */

if (!module.parent) {
  app.start()
}