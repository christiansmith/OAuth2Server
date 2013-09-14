/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , expect = chai.expect
  , request = require('supertest')
  , app = require(path.join(cwd, 'app')) 
  , Modinha = require('modinha') 
  , User = require(path.join(cwd, 'models/User'))
  , Client = require(path.join(cwd, 'models/Client'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))
  ;


console.log(Modinha.adapter)
console.log(User.adapter)


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

  var client, validClient = {
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'    
  };

  before(function (done) {
    User.backend.reset();
    Client.backend.reset();
    AccessToken.backend.reset();

    User.create(validUser, function (err, instance) {
      user = instance;

      Client.create(validClient, function (err, instance) {
        client = instance;

        AccessToken.issue(client, user, { scope: 'https://authorizationserver.tld' }, function (err, instance) {
          token = instance;
          done();
        });
      });
    });
  });


  describe('GET /v1/user', function () {

    describe('with missing access token', function () {

      before(function (done) {
        request(app)
          .get('/v1/user')
          .end(function (error, response) {
            res = response;
            done();
          });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
              
      it('should respond with an "invalid_request" error', function () {
        res.body.error.should.equal('invalid_request');
      });  

      it('should respond with a "Missing access token" error description', function () {
        res.body.error_description.should.equal('Missing access token');
      });

    });

    describe('with unknown access token', function () {

      before(function (done) {
        request(app)
          .get('/v1/user')
          .set('Authorization', 'Bearer UNKNOWN')
          .end(function (error, response) {
            res = response;
            done();
          });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
              
      it('should respond with an "invalid_request" error', function () {
        res.body.error.should.equal('invalid_request');
      });  

      it('should respond with a "Unknown access token" error description', function () {
        res.body.error_description.should.equal('Unknown access token');
      });

    });

    describe('with expired access token', function () {});

    describe('with insufficient scope', function () {});
    
    describe('with valid access token', function () {

      before(function (done) {
        request(app)
          .get('/v1/user')
          .set('Authorization', 'Bearer ' + token.access_token)
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
        res.body.created.should.equal(JSON.parse(JSON.stringify(user)).created);
      });

    });

  });


  describe('POST /v1/user', function () {

    describe('with missing access token', function () {

      before(function (done) {
        request(app)
          .post('/v1/user')
          .send({})
          .end(function (error, response) {
            res = response;
            done();
          });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
              
      it('should respond with an "invalid_request" error', function () {
        res.body.error.should.equal('invalid_request');
      });  

      it('should respond with a "Missing access token" error description', function () {
        res.body.error_description.should.equal('Missing access token');
      });

    });

    describe('with unknown access token', function () {

      before(function (done) {
        request(app)
          .post('/v1/user')
          .set('Authorization', 'Bearer UNKNOWN')
          .send({})
          .end(function (error, response) {
            res = response;
            done();
          });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
              
      it('should respond with an "invalid_request" error', function () {
        res.body.error.should.equal('invalid_request');
      });  

      it('should respond with a "Unknown access token" error description', function () {
        res.body.error_description.should.equal('Unknown access token');
      });

    });

    describe('with expired access token', function () {});

    describe('with insufficient scope', function () {});
    
    describe('with valid access token and valid request', function () {

      before(function (done) {
        request(app)
          .post('/v1/user')
          .set('Authorization', 'Bearer ' + token.access_token)
          .send({ first: 'Joe' })
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
        res.body.first.should.equal('Joe');
      });

      it('should store the update', function () {
        User.backend.documents[0].first.should.equal('Joe')
      });

    });

    describe('with valid access token and invalid request', function () {

      before(function (done) {
        request(app)
          .post('/v1/user')
          .set('Authorization', 'Bearer ' + token.access_token)
          .send({ email: 'not-valid' })
          .end(function (error, response) {
            res = response;
            done();
          });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
              
      it('should respond with a validation error', function () {
        res.body.errors.email.should.be.defined;
      });

      it('should not store the update', function () {
        User.backend.documents[0].first.should.not.equal('not-valid');
      });

    });    

  });

});