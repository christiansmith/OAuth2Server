/**
 * Module dependencies
 */

var _ = require('underscore')
  , util = require('util')
  , revalidator = require('revalidator')


/**
 * Add a format extension for UUID
 */

var uuidFormat = /[0-9a-f]{22}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
revalidator.validate.formatExtensions.uuid = uuidFormat


/**
 * Validate function
 * 
 * After validating, we transform the array of errors objects 
 * provided by revalidator.validate into an object keyed by 
 * property, for easier lookup.
 */

function validate (data, schema) {
  var validation, errorProperties;
  
  validation = revalidator.validate(data, {properties: schema});
  errorProperties = _.pluck(validation.errors, 'property');

  validation.errors = _.object(errorProperties, validation.errors);
  return new ValidationError(validation);
};


/**
 * Validation error
 */

function ValidationError (validation) {
  _.extend(this, validation);
  this.name = 'ValidationError';
  this.message = 'Validation error.';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
} 

util.inherits(ValidationError, Error);
validate.ValidationError = ValidationError;

/**
 * Exports
 */

module.exports = validate;