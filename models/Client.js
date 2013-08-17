/**
 * Module dependencies
 */

var validate = require('../lib/validate')
  , Backend  = require('./Backend')
  , backend  = new Backend()
  ;


/**
 * Constructor
 */

function Client (attrs) {
  var schema = Client.schema
    , self = this;

  function set(keys, source, target) {
    keys.forEach(function (key) {
      if (attrs[key] && schema[key].properties) {
        if (!self[key]) { 
          self[key] = {}; 
        }
        set(Object.keys(schema[key].properties), attrs[key], self[key]);
      } else {
        if (source[key]) { 
          target[key] = source[key]; 
        }
      }
    });
  }

  if (attrs) {
    set(Object.keys(schema), attrs, self);
  } 
};


/**
 * Schema
 */

Client.schema = {
  _id:         { type: 'any' },
  type:        { type: 'string', enum: ['confidential', 'public'], required: true },
  name:        { type: 'string' },
  website:     { type: 'string' },
  description: { type: 'string' },
  logo:        { type: 'string' },
  terms:       { type: 'boolean' },
  secret:      { type: 'string' },
  created:     { type: 'any' },
  modified:    { type: 'any' }
};


/**
 * Validate data against the Client schema.
 */

Client.prototype.validate = function() {
  return validate(this, Client.schema);
};


/**
 * Create client
 */

//Client.create = function (attrs, callback) {
//  var token = new Client(attrs)
//    , validation = token.validate();
//
//  if (!validation.valid) { return callback(validation); }
//
//  var now = new Date();
//  token.created = now;
//  token.modified = now;
//
//  Backend.save(token, function (err, token) {
//    if (err) { return callback(err); }
//    callback(null, token);
//  });
//};


/**
 * Find client
 */

//Client.find = function (conditions, options, callback) {
//  if (callback === undefined) {
//    callback = options;
//    options = {};
//  }
//
//  Backend.find(conditions, function (err, data) {
//    if (err) { return callback(err); }
//    if (!data) { return callback(null, data); }
//    callback(null, new Client(data));
//  });
//};


/**
 * Exports
 */

Client.backend = backend;
module.exports = Client;