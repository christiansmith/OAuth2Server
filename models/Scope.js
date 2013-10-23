/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , redis   = require('redis')
  , client  = redis.createClient();


/**
 * Model definition
 */

var Scope = Modinha.extend('Scopes', null, {
  schema: {
    url:         { type: 'string', required: true, format: 'url' },
    description: { type: 'string', required: true }
  }
});


/**
 * Set scope
 */

Scope.set = function (data, callback) {
  var scope = new Scope(data)
    , validation = scope.validate();

  if (!validation.valid) { return callback(validation); }

  client.hset('scopes', scope.url, JSON.stringify(scope), function (err) {
    if (err) { return callback(err); }
    callback(null, scope);
  });
};


/**
 * Get scopes
 */

Scope.get = function (urls, callback) {
  client.hmget('scopes', urls, function (err, scopes) {
    if (err) { return callback(err); }

    scopes = scopes.map(function (scope) {
      return JSON.parse(scope);
    });

    if (typeof urls === 'string' && scopes.length === 1) {
      scopes = scopes[0]
    }

    callback(null, scopes);
  });
}


/**
 * Exports
 */

module.exports = Scope;