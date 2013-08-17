/**
 * Module dependencies
 */

var util      = require('util')
  , async     = require('async')
  , bcrypt    = require('bcrypt')
  , validate  = require('../lib/validate')
  , Backend = require('./Backend')
  , backend = new Backend()
  ;


/**
 * User constructor
 */

function User (attrs) {
  var schema = User.schema
    , self = this;
  
  // recurse through the schema properties
  // and copy values from the provided attrs
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

  if (!self['_id']) { self['_id'] = backend.createID(); }
}

/**
 * User schema (used by User.validate)
 */

User.schema = {
  _id:  { type: 'any' },
  info: { 
    type: 'object', 
    required: true, 
    properties: {
      id:         { type: 'any' },
      first:      { type: 'string' },
      last:       { type: 'string' },
      username:   { type: 'string' },
      email:      { type: 'string', required: true, format: 'email' },
      created:    { type: 'any' },
      modified:   { type: 'any' }
    }
  },
  salt: { type: 'string' },
  hash: { type: 'string' }
};



/**
 * Validate data against the User schema.
 */

User.prototype.validate = function() {
  return validate(this, User.schema);
};


/**
 * User.create(info, callback)
 */

User.create = function (attrs, callback) {
  var user = new User({ info: attrs })
    , validation = user.validate()
    ;

  if (!validation.valid) { return callback(validation); }
  if (!attrs.password) { return callback(new PasswordRequiredError()); }

  user.salt = bcrypt.genSaltSync(10);
  user.hash = bcrypt.hashSync(attrs.password, user.salt);

  var now = new Date();
  user.info.created = now;
  user.info.modified = now;

  async.parallel({

    registeredEmail: function (done) {
      backend.find({ 'info.email': user.info.email }, function (err, data) {
        if (err) { return done(err); }
        if (data) { return done(new RegisteredEmailError()); }
        done(null, data);
      }); 
    },
    
    registeredUsername: function (done) {
      backend.find({ 'info.username': user.info.username }, function (err, data) {
        if (err) { return done(err); }
        if (data) { return done(new RegisteredUsernameError()); }
        done(null, data);
      });      
    }

  }, function (err, result) {
    if (err) { return callback(err); }
    backend.save(user, function (err) {
      if (err) { return callback(err); }
      callback(null, user);
    });
  });
};


/**
 * User.find(id, callback)
 */

User.find = function (conditions, options, callback) {
  if (callback === undefined) {
    callback = options;
    options = {};
  }

  backend.find(conditions, options, function (err, data) {
    if (err) { return callback(err); }
    if (!data) { return callback(null, data); }
    callback(null, new User(data));
  });
};


/**
 * user.verifyPassword(password, callback)
 */

User.prototype.verifyPassword = function (password, callback) {
  if (!this.hash) { return callback(null, false); }
  bcrypt.compare(password, this.hash, callback);
};

/**
 * User.authenticate(email, password, callback)
 */

User.authenticate = function (email, password, callback) {
  backend.find({ 'info.email': email }, function (err, result) {
    if (!result) { return callback(null, false, { message: 'Unknown user.' }); }

    user = new User(result);
    user.verifyPassword(password, function (err, match) {
      if (match) {
        callback(null, user, { message: 'Authenticated successfully!' });
      } else {
        callback(null, false, { message: 'Incorrect password.'});
      }
    });
  });
};



/**
 * PasswordRequiredError
 */

function PasswordRequiredError() {
  this.name = 'PasswordRequiredError';
  this.message = 'A password is required';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(PasswordRequiredError, Error);


/**
 * RegisteredEmailError
 */

function RegisteredEmailError() {
  this.name = 'RegisteredEmailError';
  this.message = 'Email already registered';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(RegisteredEmailError, Error);


/**
 * RegisteredUsernameError
 */

function RegisteredUsernameError() {
  this.name = 'RegisteredUsernameError';
  this.message = 'Username already registered';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(RegisteredUsernameError, Error);


/**
 * Exports
 */

User.backend = backend;
module.exports = User;