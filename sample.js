/**
 * Generate some sample data. It will be written to whatever backend 
 * is configured for Modinha.
 */

var async       = require('async')
  , Faker       = require('Faker')
  , app         = require('./app')
  , Account     = require('./models/Account')
  , App         = require('./models/App')
  , Service     = require('./models/Service')
  , Token       = require('./models/Token')
  , Credentials = require('./models/Credentials')
  , Scope       = require('./models/Scope')
  ;


async.waterfall([

  function (callback) {
    setTimeout(function () { console.log('now...');callback(null); }, 3000)
  },

  function (callback) {
    Credentials.insert({
      role: 'admin'
    }, function (err, credentials) {
      console.log('CREDENTIALS', err || credentials);
      if (err) { return callback(err); }
      callback(null, credentials);
    });
  },

  function (credentials, callback) {
    Account.insert({
      accountname: Faker.Internet.userName(),
      email: Faker.Internet.email(),
      password: 'secret1337'
    }, function (err, account) {
      console.log('ACCOUNT', err || account);
      if (err) { return callback(err); }
      callback(null, account);      
    });
  },

  function (account, callback) {
    App.insert({
      account_id: account._id,
      type: 'confidential',
      name: Faker.Company.companyName(),
      redirect_uri: 'someuri'
    }, function (err, app) {
      console.log('APP', err || app);
      if (err) { return callback(err); }
      callback(null, account, app);      
    });
  },

  function (account, app, callback) {
    Service.insert({
      uri: 'https://protected.tld',
      scopes: [
        { 'https://protected.tld': 'access everything on this server' }
      ]
    }, function (err, resource) {
      console.log('RESOURCE', err || resource);
      if (err) { return callback(err); }
      callback(null, account, app, resource);
    });
  },

  function (account, app, resource, callback) {
    Token.issue(app, account, { scope: 'https://authorizationserver.tld' }, function (err, token) {
      console.log('ACCESS TOKEN', err || token);
      if (err) { return callback(err); }
      callback(null);
    }); 
  }

], function (err, result) {
  console.log('Generated data.');
});
