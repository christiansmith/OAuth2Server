/**
 * Module dependencies
 */

var Modinha = require('modinha')
  , redis   = require('redis')
  , client  = redis.createClient();


/**
 * Model definition
 */

var Scope = Modinha.define('scopes', {
  url:         { type: 'string', required: true, format: 'url' },
  description: { type: 'string', required: true }
});


/**
 * Set scope
 */

Scope.set = function (data, callback) {
  var scope = new Scope(data)
    , validation = scope.validate();

  if (!validation.valid) { return callback(validation); }

  client.hset('scopes', scope.url, Scope.serialize(scope), function (err) {
    if (err) { return callback(err); }
    callback(null, scope);
  });
};


/**
 * Get scopes
 */

Scope.get = function (ids, options, callback) {
  var Constructor = this;

  if (!callback) {
    callback = options;
    options = {};
  }

  if (typeof ids === 'string') { 
    options.first = true;
  }

  options.nullify = true;

  client.hmget(Constructor.collection, ids, function (err, result) {
    if (err) { return callback(err); }
    callback(null, Constructor.initialize(result, options));
  });
}


/**
 * Exports
 */

module.exports = Scope;