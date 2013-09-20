/**
 * Generate some sample data. It will be written to whatever backend 
 * is configured for Modinha.
 */

var async       = require('async')
  , Faker       = require('Faker')
  , app         = require('./app')
  , User        = require('./models/User')
  , Client      = require('./models/Client')
  , Resource    = require('./models/Resource')
  , AccessToken = require('./models/AccessToken')
  , Credentials = require('./models/HTTPCredentials')
  ;


async.waterfall([

  function (callback) {
    setTimeout(function () { console.log('now...');callback(null); }, 3000)
  },

  function (callback) {
    Credentials.create({
      role: 'administrator'
    }, function (err, credentials) {
      console.log('CREDENTIALS', err || credentials);
      if (err) { return callback(err); }
      callback(null, credentials);
    });
  },

  function (credentials, callback) {
    User.create({
      username: Faker.Internet.userName(),
      email: Faker.Internet.email(),
      password: 'secret'
    }, function (err, user) {
      console.log('USER', err || user);
      if (err) { return callback(err); }
      callback(null, user);      
    });
  },

  function (user, callback) {
    Client.create({
      user_id: user._id,
      type: 'confidential',
      name: Faker.Company.companyName(),
      redirect_uris: ['https://anvil.io/callback.html']
    }, function (err, client) {
      console.log('CLIENT', err || client);
      if (err) { return callback(err); }
      callback(null, user, client);      
    });
  },

  function (user, client, callback) {
    Resource.create({
      uri: 'https://protected.tld',
      scopes: [
        { 'https://protected.tld': 'access everything on this server' }
      ]
    }, function (err, resource) {
      console.log('RESOURCE', err || resource);
      if (err) { return callback(err); }
      callback(null, user, client, resource);
    });
  },

  function (user, client, resource, callback) {
    AccessToken.issue(client, user, { scope: 'https://authorizationserver.tld' }, function (err, token) {
      console.log('ACCESS TOKEN', err || token);
      if (err) { return callback(err); }
      callback(null);
    }); 
  }

], function (err, result) {
  console.log('Generated data.');
});
