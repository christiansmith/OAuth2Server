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
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * User Registration Spec
 */

describe('User Registration', function () {


  var validUser = {
    email:    'valid@example.com',
    username: 'johnsmith',
    password: 'secret'
  }


  describe('POST /account', function () {


    it('should require SSL');


    describe('with valid details', function () {

      before(function (done) {
        User.backend.reset();
        request(app)
          .post('/account')
          .send(validUser)
          .end(function (err, response) {
            res = response;
            done();
          });
      });

      it('should respond 201', function () {
        res.statusCode.should.equal(201);
      });
        
      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });
        
      it('should respond with user info', function () {
        res.body.authenticated.should.equal(true);
        res.body.user.email.should.equal(validUser.email);
      });

    });


    describe('with registered email', function () {

      before(function (done) {
        User.backend.reset();
        User.create(validUser, function () {
          request(app)
            .post('/account')
            .send(validUser)
            .end(function (err, response) {
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
        
      it('should respond with "Email already registered" error', function () {
        res.body.error.should.contain('Email already registered');
      });
     
    });


    describe('with registered username', function () {

      before(function (done) {
        User.backend.reset();
        User.create(validUser, function () {
          request(app)
            .post('/account')
            .send({
              email: 'other@example.com',
              username: validUser.username,
              password: validUser.password
            })
            .end(function (err, response) {
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
        
      it('should respond with "Username already registered" error', function () {
        res.body.error.should.contain('Username already registered');
      });

    });


    describe('with invalid details', function () {

      before(function (done) {
        request(app)
          .post('/account')
          .send({
            email: 'not-email',
            password: 'secret'
          })
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
        
      it('should respond with validation errors', function () {
        res.body.errors.email.attribute.should.equal('format');
      });

    });

  });

});