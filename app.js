var express = require('express')
  , passport = require('passport')
  , app = express()
  ;


require('./config/')(app);
require('./config/passport')(passport);
require('./config/oauth2')(app);
require('./routes/')(app);


module.exports = app;

if (!module.parent) {
  app.listen(app.settings.port, function () {
    console.log(
        'OAuth2Server is running on port ' + app.settings.port
    );   
  });
}