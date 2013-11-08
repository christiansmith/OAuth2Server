/**
 * Module dependencies
 */

var redis         = require('redis')
  , client        = redis.createClient()
  , util          = require('util')
  , bcrypt        = require('bcrypt')
  , CheckPassword = require('mellt').CheckPassword
  , Modinha       = require('modinha')
  , RedisDocument = require('./RedisDocument')
  , uuid          = Modinha.defaults.uuid
  ;


/**
 * Model definition
 */

var Account = Modinha.define('accounts', {
  _id:      { type: 'string', default: uuid, format: 'uuid' },
  name:     { type: 'string' }, 
  email:    { type: 'string', required: true, format: 'email' },
  roles:    { type: 'array',  default: [] },
  hash:     { type: 'string', private: true },
  created:  { type: 'number' }, 
  modified: { type: 'number' }
});


/**
 * Document persistence
 */

Account.extend(RedisDocument);


/**
 * Create
 */

Account.create = function (data, callback) {
  var collection = Account.collection
    , account    = Account.initialize(data)
    , validation = account.validate()
    ;

  // require a password
  if (!data.password) {
    return callback(new PasswordRequiredError());
  }

  // check the password strength
  if (CheckPassword(data.password) === -1) {
    return callback(new InsecurePasswordError());
  }

  // hash the password
  if (data.password) {
    data.salt    = bcrypt.genSaltSync(10)
    account.hash = bcrypt.hashSync(data.password, data.salt);
  }

  // require a valid account
  if (!validation.valid) { 
    return callback(validation); 
  }

  // set timestamps
  var timestamp = Date.now();
  if (!account.created)  { account.created  = timestamp; }
  if (!account.modified) { account.modified = timestamp; }

  // verify the email is unique
  Account.findByEmail(account.email, function (err, found) {
    if (found) { 
      return callback(new RegisteredEmailError()); 
    }

    // store and index the account
    client.multi()
      .hset(collection, account._id, Account.serialize(account))
      .zadd(collection + ':_id', account.created, account._id)
      .hset(collection + ':email', account.email, account._id)
      .exec(function (err) {
        if (err) { return callback(err); }
        callback(null, account);
      });
  });
};


/**
 * Find by email
 */

Account.findByEmail = function (email, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }

  client.hget(this.collection + ':email', email, function (err, id) {
    if (err) { return callback(err); }
    Account.get(id, options, function (err, account) {
      if (err) { return callback(err); }
      callback(null, account);
    });
  });
};


/**
 * Verify password
 */

Account.prototype.verifyPassword = function (password, callback) {
  if (!this.hash) { return callback(null, false); }
  bcrypt.compare(password, this.hash, callback);
};


/**
 * Authenticate
 */

Account.authenticate = function (email, password, callback) {
  Account.findByEmail(email, { private: true}, function (err, account) {
    if (!account) { 
      return callback(null, false, { message: 'Unknown account.' });
    }

    account.verifyPassword(password, function (err, match) {
      if (match) {
        callback(null, Account.initialize(account), { message: 'Authenticated successfully!' });
      } else {
        callback(null, false, { message: 'Invalid password.' })
      }
    })
  })
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
 * PasswordRequiredError
 */

function InsecurePasswordError() {
  this.name = 'InsecurePasswordError';
  this.message = 'Password must be complex.';
  this.statusCode = 400;
  Error.call(this, this.message);
  Error.captureStackTrace(this, arguments.callee);
}

util.inherits(InsecurePasswordError, Error);


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
 * Exports
 */

module.exports = Account;