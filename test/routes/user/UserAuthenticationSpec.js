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




describe('User Authentication', function () {

  var res;

  var user, validUser = {
    email: 'valid@example.com',
    password: 'secret'    
  };


  describe('POST /login', function () {

    before(function (done) {
      User.backend.reset();
      User.create(validUser, function (err, instance) {
        user = instance;
        done();
      });
    });

    describe('with valid credentials', function () {

      before( function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: validUser.email,
            password: validUser.password
          })
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
              
      it('should respond with user info', function () {
        res.body.authenticated.should.equal(true);
        res.body.user.created.should.equal(JSON.parse(JSON.stringify(user.info)).created);
      });

    });

    describe('without credentials', function () {

      before( function (done) {
        request(app)
          .post('/login')
          .send({})
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
        
      it('should respond with "Missing credentials" error', function () {
        res.body.error.should.contain('Missing credentials');
      });

    });

    describe('with unknown user', function () {

      before(function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: 'unknown@example.com',
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
        
      it('should respond with "Unknown user" error', function () {
        res.body.error.should.contain('Unknown user');
      });

    });

    describe('with invalid password', function () {

      before(function (done) {
        request(app)
          .post('/login')
          .send({ 
            email: validUser.email,
            password: 'wrong'
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
        
      it('should respond with "Invalid password" error', function () {
        res.body.error.should.contain('Invalid password');
      });

    });

  });


  describe('POST /logout', function () {

    before(function (done) {
      request(app)
        .post('/logout')
        .end(function (err, response) {
          res = response;
          done();
        });
    });

    it('should respond 204', function () {
      res.statusCode.should.equal(204);
    });

  });


  describe('GET /session', function () {

    describe('with authenticated user', function () {

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
            var req = request(app).get('/session');
            agent.attachCookies(req);
            req.end(function (err, response) {
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

      it('should respond with authentication status', function () {
        res.body.authenticated.should.equal(true);
      });

      it('should respond with user info', function () {
        res.body.user.created.should.equal(JSON.parse(JSON.stringify(user.info)).created);
      });

    });

    describe('with unauthenticated user', function () {

      var agent = request.agent();

      before(function (done) {
        request(app)
          .get('/session')
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

      it('should respond with authentication status', function () {
        res.body.authenticated.should.equal(false);
      });

      it('should NOT respond with user info', function () {
        expect(res.body.user).equals(undefined);
      });

    });

  });


  describe('password reset', function () {

  });


  describe('account verification', function () {

  });


});