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


/**
 * Should style assertions
 */

chai.should();


/**
 * Client Registration Spec
 */

describe('Client Registration', function () {


  var res;


  var user, validUser = {
    email: 'valid@example.com',
    password: 'secret'
  };


  var client, validClient = {
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'
  };


  describe('POST /clients', function () {

    before(function (done) {
      User.backend.reset();
      User.create(validUser, function (err, instance) {
        user = instance;
        done();
      })
    });


    it('should require SSL');


    describe('with unauthenticated user', function () {

      before(function (done) {
        request(app)
          .post('/clients')
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
        res.text.should.equal('Unauthorized');
      });

    });


    describe('with valid details', function () {

      var agent = request.agent();

      before(function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: validUser.email,
            password: validUser.password
          })
          .end(function (err, r) {
            agent.saveCookies(r);
            var req = request(app).post('/clients');
            agent.attachCookies(req);
            req.send(validClient)
            req.end(function (err, response) {
              res = response;
              done();
            });
          });      
      });

      it('should respond with 201', function () {
        res.statusCode.should.equal(201);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should respond with the client', function () {
        res.body.type.should.equal('confidential');
      });

      it('should respond with the client secret', function () {
        res.body.secret.should.be.defined;
      });

    });


    describe('with invalid details', function () {

      var agent = request.agent();

      before(function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: validUser.email,
            password: validUser.password
          })
          .end(function (err, r) {
            agent.saveCookies(r);
            var req = request(app).post('/clients');
            agent.attachCookies(req);
            req.send({})
            req.end(function (err, response) {
              res = response;
              done();
            });
          });      
      });

      it('should respond with 400', function () {
        res.statusCode.should.equal(400);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should respond with validation errors', function () {
        res.body.errors.should.be.defined;
      });


    });

  });

});