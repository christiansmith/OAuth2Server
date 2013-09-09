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
  , Resource = require(path.join(cwd, 'models/Resource')) 
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * Resource Registration Spec
 */

describe('Resource REST Routes', function () {


  var res, credentials, resource, validResource = {
    user_id: '1234',
    uri: 'https://protected.tld'
  };


  before(function (done) {
    Credentials.create({ role: 'administrator' }, function (e, c) {
      credentials = c;

      Resource.create(validResource, function (error, instance) {
        resource = instance;
        done();
      });
    });
  });


  it('should require SSL');


  describe('GET /v1/resources', function () {

  });


  describe('GET /v1/resources/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        request(app)
          .get('/v1/resources/' + resource._id)
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
          .get('/v1/resources/' + resource._id)
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

      it('should respond with a resource', function () {
        res.body.uri.should.equal(validResource.uri);
      });

    });

    describe('with unknown access token', function () {
      it('should respond 404');
    });

  });


  describe('POST /v1/resources', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Resource.backend.reset();
        request(app)
          .post('/v1/resources')
          .send(validResource)
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
        Resource.backend.reset();
        request(app)
          .post('/v1/resources')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
          .send(validResource)
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

      it('should create a new resource', function () {
        Resource.backend.documents[0].uri.should.equal(validResource.uri);
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        Resource.backend.reset();
        request(app)
          .post('/v1/resources')
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


  describe('PUT /v1/resources/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Resource.backend.reset();
        Resource.create(validResource, function (err, instance) {
          request(app)
            .put('/v1/resources/' + instance._id)
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
        Resource.backend.reset();
        Resource.create(validResource, function (err, instance) {
          request(app)
            .put('/v1/resources/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ uri: 'changed' })
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

      it('should update a resource', function () {
        Resource.backend.documents[0].uri.should.equal('changed');
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        Resource.backend.reset();
        Resource.create(validResource, function (err, instance) {
          request(app)
            .put('/v1/resources/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ uri: {} })
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


  describe('DELETE /v1/resources/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Resource.backend.reset();
        Resource.backend.documents.length.should.equal(0);

        Resource.create(validResource, function (err, instance) {
          request(app)
            .del('/v1/resources/' + instance._id)
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
        Resource.backend.reset();
        Resource.backend.documents.length.should.equal(0);

        Resource.create(validResource, function (err, instance) {
          request(app)
            .del('/v1/resources/' + instance._id)
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
        Resource.backend.documents.length.should.equal(0);
      });

    });

    describe('with unknown access token', function () {
      it('should respond 404');
    });

  });

});