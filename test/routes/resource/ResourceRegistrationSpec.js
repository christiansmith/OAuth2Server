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
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * Resource Registration Spec
 */

describe('Resource Registration', function () {


  var res;


  var resource, user, validUser = {
    email: 'valid@example.com',
    password: 'secret'
  };


  describe('POST /resources', function () {

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
          .post('/resources')
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

      var uri = 'https://protected.tld'
        , agent = request.agent()
        ;

      before(function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: validUser.email,
            password: validUser.password
          })
          .end(function (err, r) {
            agent.saveCookies(r);
            var req = request(app).post('/resources');
            agent.attachCookies(req);
            req.send({ uri: uri })
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

      it('should respond with the resource', function () {
        res.body.uri.should.equal(uri);
      });

      it('should respond with the resource secret', function () {
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
            var req = request(app).post('/resources');
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