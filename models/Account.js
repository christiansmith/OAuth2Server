/**
 * Module dependencies
 */

var client        = require('../config/redis')
  , bcrypt        = require('bcrypt')
  , CheckPassword = require('mellt').CheckPassword
  , Modinha       = require('modinha')
  , Document      = require('modinha-redis')
  , App           = require('./App')
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
  hash:     { type: 'string', private: true, set: hashPassword }
});


/**
 * Hash Password Setter
 */

function hashPassword (data) {
  var password = data.password
    , hash     = data.hash
    ;

  if (password) {
    var salt = bcrypt.genSaltSync(10);
    hash = bcrypt.hashSync(password, salt);
  }

  this.hash = hash;
}


/**
 * Document persistence
 */

Account.extend(Document);
Account.__client = client;


/**
 * Account intersections
 */

Account.intersects('roles');
Account.intersects('groups');


/**
 * Create
 */

Account.insert = function (data, options, callback) {
  var collection = Account.collection;

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

  // create an instance
  var account = Account.initialize(data, { private: true })
    , validation = account.validate()
    ;

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
 * Account apps
 */

Account.listApps = function (accountId, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }

  options.index = 'accounts:' + accountId + ':apps';

  App.list(options, function (err, apps) {
    if (err) { return callback(err); }
    callback(null, apps);
  });

};


/**
 * Account group membership
 */

Account.prototype.isAppGroupsMember = function (app, callback) {
  var accountGroups = 'accounts:'+this._id+':groups'
    , appGroups = 'apps:'+app._id+':groups'
    ;

  Account.__client.zinterstore(
    'account:app:groups:tmp', 2,
    accountGroups, appGroups,
  function (err, count) {
    if (err) { return callback(err); }
    callback(null, Boolean(count));
  });
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
