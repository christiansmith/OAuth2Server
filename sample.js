/**
 * Generate some sample data. It will be written to whatever backend 
 * is configured for Modinha.
 */

var cwd         = process.cwd()
  , path        = require('path')
  , async       = require('async')
  , Faker       = require('Faker')
  , app         = require(path.join(cwd, 'app'))
  , User        = require(path.join(cwd, 'models/User')) 
  , Client      = require(path.join(cwd, 'models/Client')) 
  , Resource    = require(path.join(cwd, 'models/Resource')) 
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))
  , Credentials = require(path.join(cwd, 'models/HTTPCredentials'))
  ;


async.waterfall([

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
      user_id: user._id,
      uri: 'https://protected.tld'
    }, function (err, resource) {
      console.log('RESOURCE', err || resource);
      if (err) { return callback(err); }
      callback(null, user, client, resource);
    });
  },

  function (user, client, resource, callback) {
    AccessToken.issue(client, user, { scope: 'limited' }, function (err, token) {
      console.log('ACCESS TOKEN', err || token);
      if (err) { return callback(err); }
      callback(null);
    }); 
  }

], function (err, result) {
  console.log('Generated data.');
});
