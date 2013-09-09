/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , expect = chai.expect
  , request = require('supertest')
  , app = require(path.join(cwd, 'app'))  
  , Credentials = require(path.join(cwd, 'models/HTTPCredentials')) 
  , User = require(path.join(cwd, 'models/User')) 
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * User Spec
 */

describe('User REST Routes', function () {


  var res, credentials, user, validUser = {
    email: 'valid@example.com',
    password: 'secret'
  };


  before(function (done) {
    Credentials.create({ role: 'administrator' }, function (e, c) {
      credentials = c;

      User.backend.reset();
      User.create(validUser, function (error, instance) {
        user = instance;
        done();
      });
    });
  });


  it('should require SSL');


  describe('GET /v1/users', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        request(app)
          .get('/v1/users')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':wrong').toString('base64'))
          .end(function (error, response) {
            err = error;
            res = response;
            done();
          });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond "Unauthorized"', function () {
        res.text.should.equal('Unauthorized');
      });

    });

    describe('with valid request', function () {

      before(function (done) {
        request(app)
          .get('/v1/users')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
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

      it('should respond with users', function () {
        res.body[0].info.email.should.equal(validUser.email);
      });

    });

  });


  describe('GET /v1/users/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        request(app)
          .get('/v1/users/' + user._id)
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':wrong').toString('base64'))
          .end(function (error, response) {
            err = error;
            res = response;
            done();
          });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond "Unauthorized"', function () {
        res.text.should.equal('Unauthorized');
      });

    });

    describe('with valid request', function () {

      before(function (done) {
        request(app)
          .get('/v1/users/' + user._id)
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
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

      it('should respond with a user', function () {
        res.body.info.email.should.equal(validUser.email);
      });

    });

    describe('with unknown user id', function () {
      it('should respond 404');
    });

  });


  describe('POST /v1/users', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        User.backend.reset();
        request(app)
          .post('/v1/users')
          .send(validUser)
          .end(function (error, response) {
            err = error;
            res = response;
            done();
          });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond "Unauthorized"', function () {
        res.text.should.equal('Unauthorized');
      });

    });


    describe('with valid request', function () {

      before(function (done) {
        User.backend.reset();
        request(app)
          .post('/v1/users')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
          .send(validUser)
          .end(function (error, response) {
            err = error;
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

      it('should create a new user', function () {
        User.backend.documents[0].info.email.should.equal(validUser.email);
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        User.backend.reset();
        request(app)
          .post('/v1/users')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
          .send({})
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

      it('should respond with validation errors', function () {
        res.body.errors.should.be.defined;
      });

    });

  });


  describe('PUT /v1/users/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        User.backend.reset();
        User.create(validUser, function (err, instance) {
          request(app)
            .put('/v1/users/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer('unknown:' + credentials.secret).toString('base64'))
            .send({ name: 'changed' })
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });
        });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond "Unauthorized"', function () {
        res.text.should.equal('Unauthorized');
      });

    });

    describe('with valid request', function () {

      before(function (done) {
        User.backend.reset();
        User.create(validUser, function (err, instance) {
          request(app)
            .put('/v1/users/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ info: { email: 'updated@example.com' } })
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });
        });
      });

      it('should respond 200', function () {
        res.statusCode.should.equal(200);
      });

      it('should respond with JSON', function () {
        res.headers['content-type'].should.contain('application/json');
      });

      it('should update a user', function () {
        User.backend.documents[0].info.email.should.equal('updated@example.com');
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        User.backend.reset();
        User.create(validUser, function (err, instance) {
          request(app)
            .put('/v1/users/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ info: { email: 'not-valid' } })
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

      it('should respond with validation errors', function () {
        res.body.errors.should.be.defined;
      });

    });

  });


  describe('DELETE /v1/users/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        User.backend.reset();
        User.backend.documents.length.should.equal(0);

        User.create(validUser, function (err, instance) {
          request(app)
            .del('/v1/users/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':wrong').toString('base64'))
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });
        });
      });

      it('should respond 401', function () {
        res.statusCode.should.equal(401);
      });

      it('should respond "Unauthorized"', function () {
        res.text.should.equal('Unauthorized');
      });

    });

    describe('with valid request', function () {

      before(function (done) {
        User.backend.reset();
        User.backend.documents.length.should.equal(0);

        User.create(validUser, function (err, instance) {
          request(app)
            .del('/v1/users/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .end(function (error, response) {
              err = error;
              res = response;
              done();
            });
        });
      });

      it('should respond 204', function () {
        res.statusCode.should.equal(204);
      });

      it('should destroy the resource', function () {
        User.backend.documents.length.should.equal(0);
      });

    });

    describe('with unknown user id', function () {
      it('should respond 404');
    });

  });

});