/**
 * Access token validation
 *
 * The OAuth 2.0 Authorization Framework
 * ...
 * http://tools.ietf.org/html/rfc6749#section-1.4
 * http://tools.ietf.org/html/rfc6749#section-7
 * http://tools.ietf.org/html/rfc6749#section-10.3
 */


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
  , Client = require(path.join(cwd, 'models/Client'))
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))
  ;


describe('access token validation', function () {


  var token, err, res;


  var user, validUser = {
    _id: '1234',
    email: 'valid@example.com',
    password: 'secret'    
  };


  var client, validClient = {
    user_id: validUser._id,
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'    
  };


  describe('POST /access', function () {

    before(function (done) {
      User.backend.reset();
      Client.backend.reset();
      AccessToken.backend.reset();

      User.create(validUser, function (err, instance) {
        user = instance;

        Client.register(validClient, function (err, instance) {
          client = instance;

          AccessToken.issue(client, user, { scope: 'https://resourceserver.tld' }, function (err, instance) {
            token = instance;

            done();
          });
        });
      });
    });


    it('should require SSL');

    describe('with valid request', function () {

      before(function (done) {
        var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');
        
        request(app)
          .post('/access')
          .set('Authorization', 'Basic ' + credentials)
          .send('access_token=' + token.access_token + '&client_id=' + client._id + '&scope=' + token.scope)
          .end(function (error, response) {
            err = error;
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

      it('should respond with ???', function () {
        res.body.authorized.should.equal(true);
      });

    });

    describe('with unauthenticated client', function () {

      before(function (done) {
        request(app)
          .post('/access')
          .end(function (error, response) {
            err = error;
            res = response;
            done();
          });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond with error', function () {
        res.text.should.equal('Unauthorized')
      });

    });


    describe('with more than one authentication method', function () {

//      before(function (done) {
//        var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');
//        
//        request(app)
//          .post('/access')
//          .set('Authorization', 'Basic ' + credentials)
//          .send('access_token=' + token.access_token + '&client_id=' + client._id + '&scope=' + token.scope)
//          .end(function (error, response) {
//            err = error;
//            res = response;
//            done();
//          });
//      });
      
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with client mismatch', function () {

      var client2;

      before(function (done) {
        Client.create(validClient, function (err, instance) {
          client2 = instance;
          var credentials = new Buffer(client2._id + ':' + client2.secret).toString('base64');
          
          request(app)
            .post('/access')
            .set('Authorization', 'Basic ' + credentials)
            .send('access_token=' + token.access_token + '&client_id=' + client2._id + '&scope=https://resourceserver.tld')
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });
        });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should respond with an "invalid_token" error', function () {
        res.body.error.should.equal('invalid_token');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('Client mismatch');
      });

      it('should respond with an error uri');

    });

    describe('with unknown access token', function () {

      before(function (done) {
        var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');
        
        request(app)
          .post('/access')
          .set('Authorization', 'Basic ' + credentials)
          .send('access_token=unknown&client_id=' + client._id + '&scope=https://resourceserver.tld')
          .end(function (error, response) {
            err = error;
            res = response;
            done();
          });        
      })

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should respond with an "invalid_token" error', function () {
        res.body.error.should.equal('invalid_token');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('Unknown access token');
      });

      it('should respond with an error uri');
    });

    describe('with expired access token', function () {

      before(function (done) {
        AccessToken.create({
          client_id: token.client_id,
          user_id: token.user_id,
          access_token: '1234abcd',
          expires_at: new Date('2012/12/21'),
          refresh_token: '3456asdf',
          scope: 'https://api1.tld https://api2.tld'
        }, function (err, instance) {
          var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');
          
          request(app)
            .post('/access')
            .set('Authorization', 'Basic ' + credentials)
            .send('access_token=' + instance.access_token + '&client_id=' + client._id + '&scope=https://resourceserver.tld')
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });  
        });
      });

      it('should respond 400', function () {
        res.statusCode.should.equal(400);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should respond with an "invalid_token" error', function () {
        res.body.error.should.equal('invalid_token');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('Expired access token');
      });

      it('should respond with an error uri');

    });

    describe('with insufficient scope', function () {

      before(function (done) {
        var credentials = new Buffer(client._id + ':' + client.secret).toString('base64');
        
        request(app)
          .post('/access')
          .set('Authorization', 'Basic ' + credentials)
          .send('access_token=' + token.access_token + '&client_id=' + client._id + '&scope=insufficient')
          .end(function (error, response) {
            err = error;
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

      it('should respond with an "insufficient_scope" error', function () {
        res.body.error.should.equal('insufficient_scope');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('Insufficient scope');
      });

      it('should respond with an error uri');

    });

    describe('without state', function () {});

  });

});