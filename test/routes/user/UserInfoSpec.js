/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , expect = chai.expect
  , request = require('supertest')
  , app = require(path.join(cwd, 'app'))  
  , User = require(path.join(cwd, 'models/User'))
  , Resource = require(path.join(cwd, 'models/Resource'))
  , Client = require(path.join(cwd, 'models/Client'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))
  ;


/**
 * Assertions
 */

chai.should();


/**
 * Spec
 */

describe('User Info', function () {

  var token, err, res;

  var user, validUser = {
    _id: '1234',
    email: 'valid@example.com',
    password: 'secret'    
  };

  var resource, validResource = {
    user_id: validUser._id,
    uri: 'https://protected.tld'
  };

  var client, validClient = {
    user_id: validUser._id,
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'    
  };

  before(function (done) {
    User.backend.reset();
    Client.backend.reset();
    Resource.backend.reset();
    AccessToken.backend.reset();

    User.create(validUser, function (err, instance) {
      user = instance;

      Client.create(validClient, function (err, instance) {
        client = instance;

        Resource.create(validResource, function (err, instance) {
          resource = instance;

          AccessToken.issue(client, user, { scope: 'https://resourceserver.tld' }, function (err, instance) {
            token = instance;

            done();
          });
        });
      });
    });
  });


  describe('GET /v1/user', function () {

    before(function (done) {
      var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');

      request(app)
        .get('/v1/user?access_token=' + token.access_token + '&scope=' + token.scope)
        .set('Authorization', 'Basic ' + credentials)
        .end(function (error, response) {
          res = response;
          done();
        });
    });

    it('should respond 200', function () {
      res.statusCode.should.equal(200);
    });
      
    it('should respond with JSON', function () {
      res.headers['content-type'].should.contain('application/json');
    });
            
    it('should respond with user info', function () {
      res.body.created.should.equal(JSON.parse(JSON.stringify(user.info)).created);
    });

  });

});