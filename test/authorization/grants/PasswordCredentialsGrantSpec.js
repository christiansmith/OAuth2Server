/**
 * Resource Owner Password Credentials Grant
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-4.3
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
  ;


describe('resource owner password credentials grant', function () {


  var res;


  describe('POST /token', function () {

    before(function (done) {
      User.backend.reset();
      Client.backend.reset();

      User.create({ email: 'valid@example.com', password: 'secret' }, function (err, user) {
        Client.create({ 
          _id: 'thirdparty', 
          secret: 'secret', 
          type: 'confidential' 
        }, done);
      });
    });

    it('should require SSL');

    describe('without client authentication', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:wrong').toString('base64'))
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


    describe('with valid request', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:secret').toString('base64'))
          .send('grant_type=password&username=valid@example.com&password=secret&scope=https://resourceserver.tld')
          .end(function (err, response) {
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

      it('should respond with an access token', function () {
        res.body.access_token.should.be.defined;
      });

      it('should respond with a token type', function () {
        res.body.token_type.should.equal('bearer');
      });

      it('should respond with expiration');

      it('should respond with a refresh token', function () {
        res.body.refresh_token.should.be.defined;
      });

    });


    describe('with unknown username', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:secret').toString('base64'))
          .send('grant_type=password&username=unknown@example.com&password=secret&scope=https://resourceserver.tld')
          .end(function (err, response) {
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

      it('should respond with an "invalid_grant" error', function () {
        res.body.error.should.equal('invalid_grant');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('invalid resource owner credentials');
      });

      it('should respond with an error uri');

    });


    describe('with missing username', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:secret').toString('base64'))
          .send('grant_type=password&password=secret&scope=https://resourceserver.tld')
          .end(function (err, response) {
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

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('missing username parameter');
      });

      it('should respond with an error uri');

    });


    describe('with mismatching password', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:secret').toString('base64'))
          .send('grant_type=password&username=valid@example.com&password=wrong&scope=https://resourceserver.tld')
          .end(function (err, response) {
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
        res.body.error.should.equal('invalid_grant');
      });

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('invalid resource owner credentials');
      });

      it('should respond with an error uri');

    });


    describe('with missing password', function () {

      before(function (done) {
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + new Buffer('thirdparty:secret').toString('base64'))
          .send('grant_type=password&username=valid@example.com&scope=https://resourceserver.tld')
          .end(function (err, response) {
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

      it('should respond with an error description', function () {
        res.body.error_description.should.equal('missing password parameter');
      });

      it('should respond with an error uri');

    });


    describe('with brute force requests', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });


    describe('when scope is required', function () {

      describe('with invalid scope', function () {
        it('should respond 400');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');      
      });

      describe('with missing scope', function () {
        it('should respond 400');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');      
      });

      describe('with excess scope', function () {
        it('should ???')
      });

    });    

  });

});