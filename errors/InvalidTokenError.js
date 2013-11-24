/**
 * Module dependencies
 */

var util = require('util');


/**
 * InvalidTokenError
 */

function InvalidTokenError(description) {
  this.name = 'InvalidTokenError';
  this.message = 'invalid_token';
  this.description = description;
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InvalidTokenError, Error);


/**
 * Exports
 */

module.exports = InvalidTokenError;