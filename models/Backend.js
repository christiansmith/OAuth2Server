/**
 * Module dependencies
 */

var _     = require('underscore');


/**
 * Mock backend
 */

function Backend () {
  this.reset();
}


/**
 * Reset documents (used for testing)
 */

Backend.prototype.reset = function() {
  this.documents = [];
};


/**
 * Generate a document ID
 */

Backend.prototype.createID = function () { 
  return '1234abcd'; 
};


/**
 * Save a document
 */

Backend.prototype.save = function (doc, callback) {
  this.documents.push(doc);
  callback(null, doc);
};
 

/**
 * Find a document
 */

Backend.prototype.find = function (conditions, options, callback) {
  if (callback === undefined) {
    callback = options;
    options = {};
  }

  var doc
    , key = Object.keys(conditions).pop()
    , keys = key.split('.');

  if (key) {
    doc = _.find(this.documents, function (doc) { 
      if (keys.length === 1) { return doc[keys[0]] === conditions[key]; }
      if (keys.length === 2) { return doc[keys[0]][keys[1]] === conditions[key]; }
    });
  }

  callback(null, doc || null);   
};


/**
 * Exports
 */

module.exports = Backend;