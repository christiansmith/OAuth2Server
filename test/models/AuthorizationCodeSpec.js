var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , AuthorizationCode = require(path.join(cwd, 'models/AuthorizationCode'))
  , expect = chai.expect
  ;


/**
 * AuthorizationCode model
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-4.1.2
 * http://tools.ietf.org/html/rfc6749#section-10.5
 */

describe('AuthorizationCode', function () {

  var err, authorization, validation, validAuthorization = {
    client_id: '0987qwer',
    code: '6789hjkl',
    expires_at: new Date('2014/01/31')
  };

  beforeEach(function () { 
    AuthorizationCode.backend.reset(); 
  });

  describe('schema', function () {

    beforeEach(function () {
      code = new AuthorizationCode();
      validation = code.validate();
    });

    it('should require a client id', function () {
      validation.errors.client_id.attribute.should.equal('required');
    });

    it('should require a code', function () {
      validation.errors.code.attribute.should.equal('required');
    });

    it('should have an expiration', function () {
      AuthorizationCode.schema.expires_at.type.should.equal('any');
    });

    it('should have "created" timestamp', function () {
      AuthorizationCode.schema.created.should.be.an('object');
    });
    
    it('should have "modified" timestamp', function () {
      AuthorizationCode.schema.modified.should.be.an('object');
    });
   
  });


  describe('constructor', function () {

    it('should set attrs defined in schema', function () {
      authorization = new AuthorizationCode(validAuthorization);
      authorization.client_id.should.equal(validAuthorization.client_id);
      authorization.code.should.equal(validAuthorization.code);
      authorization.expires_at.should.equal(validAuthorization.expires_at);
    });
    
    it('should ignore attrs not defined in schema', function () {
      authorization = new AuthorizationCode({ hacker: 'p0wn3d' });
      expect(authorization.hacker).equals(undefined);
    });

  });


  describe('creation', function () {

    describe('with valid data', function () {

      before(function (done) {
        AuthorizationCode.create(validAuthorization, function (error, instance) {
          err = error; 
          token = instance; 
          done();
        });
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      });

      it('should provide an AuthorizationCode instance', function () {
        (token instanceof AuthorizationCode).should.equal(true);
      });      

      it('should set the "created" timestamp', function () {
        token.created.should.be.defined;
      });

      it('should set the "modified" timestamp', function () {
        token.modified.should.be.defined;
      });

    });

    describe('with invalid data', function () {

      beforeEach(function (done) {
        AuthorizationCode.create({}, function (error, instance) {
          err = error; 
          token = instance; 
          done();
        });
      });

      it('should provide a validation error', function () {
        err.name.should.equal('ValidationError');
      });

      it('should not provide an access token', function () {
        expect(token).equals(undefined);
      });

    });

  });


  describe('retrieval', function () {

    describe('by code', function () {

      before(function (done) {
        AuthorizationCode.create(validAuthorization, function (e) {
          AuthorizationCode.find({ code: validAuthorization.code }, function (error, instance) {
            err = error;
            authorization = instance;
            done();
          });
        });        
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      })

      it('should provide an AuthorizationCode instance', function () {
        (authorization instanceof AuthorizationCode).should.equal(true);
      });

    });

  });

  describe('retrieval', function () {});
  describe('verification', function () {});

});