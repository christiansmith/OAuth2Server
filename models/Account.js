/**
 * Module dependencies
 */

var bcrypt        = require('bcrypt')
  , CheckPassword = require('mellt').CheckPassword
  , Modinha       = require('modinha')
  , Document      = require('modinha-redis')
  , PasswordRequiredError = require('../errors/PasswordRequiredError')
  , InsecurePasswordError = require('../errors/InsecurePasswordError')
  ;


/**
 * Model definition
 */

var Account = Modinha.define('accounts', {
  name:     { type: 'string' }, 
  email:    { type: 'string', required: true, unique: true, format: 'email' },
  roles:    { type: 'array',  default: [] },
  hash:     { type: 'string', private: true }
});


/**
 * Document persistence
 */

Account.extend(Document);


/**
 * Create
 */

Account.insert = function (data, options, callback) {
  var collection = Account.collection
    , account    = Account.initialize(data, { private: true })
    , validation = account.validate()
    ;

  if (!callback) {
    callback = options;
    options = {};
  }

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

  // catch duplicate values
  Account.enforceUnique(account, function (err) {
    if (err) { return callback(err); }

    // batch operations
    var multi = Account.__client.multi()
    
    // store the account
    multi.hset(collection, account._id, Account.serialize(account))

    // index the account
    Account.index(multi, account);

    // execute ops
    multi.exec(function (err) {
      if (err) { return callback(err); }
      callback(null, Account.initialize(account, options));
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
  Account.getByEmail(email, { private: true }, function (err, account) {
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
 * Errors
 */

Account.PasswordRequiredError = PasswordRequiredError;
Account.InsecurePasswordError = InsecurePasswordError;


/**
 * Exports
 */

module.exports = Account;
