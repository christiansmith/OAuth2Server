/**
 * Module dependencies
 */

var util   = require('util')
  , async  = require('async')
  , bcrypt = require('bcrypt')
  , Model  = require('./Model')
  ;


/**
 * Model definition
 */

var User = Model.extend(null, {
  schema: {
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
  }
});


/**
 * Override Model.create. 
 * We can refactor this to define unique values in the schema
 * and automatically check. Also need a way to hook in before
 * create/validate.
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
      User.backend.find({ 'info.email': user.info.email }, function (err, data) {
        if (err) { return done(err); }
        if (data) { return done(new RegisteredEmailError()); }
        done(null, data);
      }); 
    },
    
    registeredUsername: function (done) {
      User.backend.find({ 'info.username': user.info.username }, function (err, data) {
        if (err) { return done(err); }
        if (data) { return done(new RegisteredUsernameError()); }
        done(null, data);
      });      
    }

  }, function (err, result) {
    if (err) { return callback(err); }
    User.backend.save(user, function (err) {
      if (err) { return callback(err); }
      callback(null, user);
    });
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
  User.backend.find({ 'info.email': email }, function (err, result) {
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

module.exports = User;