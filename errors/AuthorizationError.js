/**
 * Module dependencies
 */

var util = require('util');


/**
 * AuthorizationError
 */

function AuthorizationError(message, description, status) {
  this.name = 'AuthorizationError';
  this.message = message || 'invalid_request';
  this.description = description;
  this.statusCode = status || 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(AuthorizationError, Error);


/**
 * Exports
 */

module.exports = AuthorizationError;