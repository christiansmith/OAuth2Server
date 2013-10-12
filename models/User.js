/**
 * Module dependencies
 */

var util   = require('util')
  , async  = require('async')
  , bcrypt = require('bcrypt')
  , Modinha  = require('modinha')
  ;


/**
 * Model definition
 */

var User = Modinha.extend('Users', null, {
  schema: {
    first:    { type: 'string' },
    last:     { type: 'string' },
    username: { type: 'string' },
    email:    { type: 'string', required: true, format: 'email' },
    roles:    { type: 'array', default: [] },    
    salt:     { type: 'string', private: true },
    hash:     { type: 'string', private: true }    
  }
});


/**
 * Hash the password
 */

User.before('validate', function (user, attrs, callback) {
  if (!user.created && !attrs.password) { 
    return callback(new PasswordRequiredError()); 
  }

  if (attrs.password) {
    user.salt = bcrypt.genSaltSync(10);
    user.hash = bcrypt.hashSync(attrs.password, user.salt);    
  }

  callback(null);
});


/**
 * Require email to be unique
 */

User.before('create', function (user, attrs, callback) {
  User.backend.find({ email: user.email }, function (err, data) {
    if (err) { return callback(err); }
    if (data) { return callback(new RegisteredEmailError()); }
    callback(null, data);
  });
});


/**
 * Require username to be unique, if provided
 */

User.before('create', function (user, attrs, callback) {
  if (!user.username) { return callback(null); }
  User.backend.find({ username: user.username }, function (err, data) {
    if (err) { return callback(err); }
    if (data) { return callback(new RegisteredUsernameError()); }
    callback(null, data);
  }); 
});


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
  User.find({ email: email }, { private: true }, function (err, user) {
    if (!user) { return callback(null, false, { message: 'Unknown user.' }); }

    user.verifyPassword(password, function (err, match) {
      if (match) {
        callback(null, new User(user), { message: 'Authenticated successfully!' });
      } else {
        callback(null, false, { message: 'Invalid password.'});
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

module.exports = User;