module.exports = function (app) {

  return function ui (req, res, next) {
    if (req.is('json')) {
      next();
    } else {
      res.sendfile('index.html', { 
        root: app.settings['local-ui']
      });
    } 
  };

}



