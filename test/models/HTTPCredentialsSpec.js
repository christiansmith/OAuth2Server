/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , Credentials = require(path.join(cwd, 'models/HTTPCredentials')) 
  , expect = chai.expect
  ;


/**
 * Should style assertions
 */

chai.should();


/**
 * Model specification
 */

describe('HTTP Credentials', function () {


  var credentials;


  describe('schema', function () {

    beforeEach(function () {
      credentials = new Credentials();
      validation = credentials.validate();
    });

    it('should not have _id', function () {
      expect(Credentials.schema._id).equals(undefined);
    });

    it('should require a key', function () {
      Credentials.schema.key.required.should.equal(true);
    });

    it('should require a secret', function () {
      Credentials.schema.secret.required.should.equal(true);
    });

    it('should require a role', function () {
      validation.errors.role.attribute.should.equal('required');
    });

    it('should enumerate roles');

  });


  describe('creation', function () {
    
    before(function (done) {
      Credentials.create({ role: 'fake' }, function (error, instance) {
        err = error;
        credentials = instance;
        done();
      });
    });

    it('should generate a key', function () {
      credentials.key.should.be.defined;
    });

    it('should generate a secret', function () {
      credentials.secret.should.be.defined;
    });

  });

});