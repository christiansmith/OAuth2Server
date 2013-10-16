/**
 * Configuration dependencies
 */

var cwd      = process.cwd()
  , path     = require('path')  
  , config   = require(path.join(cwd, 'config.json'))
  , express  = require('express')
  , passport = require('passport') 
  , Modinha  = require('modinha')
  , cors     = require('cors')
  ;


/**
 * Exports
 */

module.exports = function (app) {

  app.configure(function () {

    // default settings
    app.set('port', process.env.PORT || config.port || 3000);
    app.set('local-ui', path.join(cwd, 'node_modules/oauth2ui/dist'));

    // config file settings
    Object.keys(config).forEach(function (key) {
      app.set(key, config[key]);
    });

    // request parsing
    app.use(express.cookieParser('secret'));
    app.use(express.bodyParser());
    
    // express session
    app.use(express.session());

    // passport authentication middleware
    app.use(passport.initialize());
    app.use(passport.session());

    app.use(cors());

    // Explicitly register app.router
    // before error handling.
    app.use(app.router);

    // Error handler
    app.use(function (err, req, res, next) {   
      var error = (err.errors)
        ? { errors: err.errors }
        : { error: err.message, error_description: err.description };
      res.send(err.statusCode || 500, error);
    });

    Modinha.adapter = config.adapter;

    // Static file server for UI
    if (app.settings['local-ui'] !== false) {
      app.use(express.static(app.settings['local-ui']))
    }
    
  });

};