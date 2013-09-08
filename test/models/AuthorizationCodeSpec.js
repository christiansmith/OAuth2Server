/**
 * Test dependencies
 */

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
      AuthorizationCode.schema.code.required.should.equal(true);
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


  describe('creation', function () {

    describe('with valid data', function () {

      var authorization;

      before(function (done) {
        AuthorizationCode.create(validAuthorization, function (error, instance) {
          err = error; 
          authorization = instance; 
          done();
        });
      });

      it('should generate a code', function () {
        authorization.code.should.be.defined;
      });      

    });

  });


  describe('verification', function () {});


});