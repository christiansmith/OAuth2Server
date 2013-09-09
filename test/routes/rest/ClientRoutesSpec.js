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
  , Client = require(path.join(cwd, 'models/Client')) 
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * Client Registration Spec
 */

describe('Client REST Routes', function () {


  var res, credentials, auth, client, validClient = {
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'
  };


  before(function (done) {
    Credentials.create({ role: 'administrator' }, function (e, c) {
      credentials = c;

      Client.backend.reset();
      Client.create(validClient, function (error, instance) {
        var auth = new Buffer(instance._id + ':' + instance.secret).toString('base64');
        client = instance;
        done();
      });
    });
  });


  it('should require SSL');


  describe('GET /v1/clients', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        request(app)
          .get('/v1/clients')
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
          .get('/v1/clients')
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

      it('should respond with clients', function () {
        console.log(res.body)
        res.body[0].name.should.equal('ThirdPartyApp');
      });

    });

  });


  describe('GET /v1/clients/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        request(app)
          .get('/v1/clients/' + client._id)
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
          .get('/v1/clients/' + client._id)
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

      it('should respond with a client', function () {
        res.body.name.should.equal('ThirdPartyApp');
      });

    });

    describe('with unknown client id', function () {
      it('should respond 404');
    });

  });


  describe('POST /v1/clients', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Client.backend.reset();
        request(app)
          .post('/v1/clients')
          .send(validClient)
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
        Client.backend.reset();
        request(app)
          .post('/v1/clients')
          .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
          .send(validClient)
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

      it('should create a new client', function () {
        Client.backend.documents[0].name.should.equal('ThirdPartyApp');
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        Client.backend.reset();
        request(app)
          .post('/v1/clients')
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


  describe('PUT /v1/clients/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Client.backend.reset();
        Client.create(validClient, function (err, instance) {
          request(app)
            .put('/v1/clients/' + instance._id)
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
        Client.backend.reset();
        Client.create(validClient, function (err, instance) {
          request(app)
            .put('/v1/clients/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ name: 'changed' })
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

      it('should update a client', function () {
        Client.backend.documents[0].name.should.equal('changed');
      });

    });

    describe('with invalid request', function () {

      before(function (done) {
        Client.backend.reset();
        Client.create(validClient, function (err, instance) {
          request(app)
            .put('/v1/clients/' + instance._id)
            .set('Authorization', 'Basic ' + new Buffer(credentials.key + ':' + credentials.secret).toString('base64'))
            .send({ type: 'wrong' })
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


  describe('DELETE /v1/clients/:id', function () {

    describe('with invalid authentication', function () {

      before(function (done) {
        Client.backend.reset();
        Client.backend.documents.length.should.equal(0);

        Client.create(validClient, function (err, instance) {
          request(app)
            .del('/v1/clients/' + instance._id)
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
        Client.backend.reset();
        Client.backend.documents.length.should.equal(0);

        Client.create(validClient, function (err, instance) {
          request(app)
            .del('/v1/clients/' + instance._id)
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

      it('should destroy the client', function () {
        Client.backend.documents.length.should.equal(0);
      });

    });

    describe('with unknown client id', function () {
      it('should respond 404');
    });

  });

});