/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , User = require(path.join(cwd, 'models/User'))  
  , Resource = require(path.join(cwd, 'models/Resource'))
  , expect = chai.expect
  ;


/**
 * Specs
 */

describe('Resource', function () {

  var user, validUser = {
    email: 'valid@example.com',
    password: 'secret'    
  };

  var err, resource, validation, validResource = {
    user_id: '1234',
    uri: 'https://protected.tld',
    secret: 'g1bb3r1sh'
  };


  beforeEach(function () { 
    Resource.backend.reset(); 
  });


  describe('schema', function () {

    beforeEach(function () {
      resource = new Resource();
      validation = resource.validate();
    });

    it('should have _id', function () {
      Resource.schema._id.should.be.an('object');
    });

    it('should require user_id', function () {
      validation.errors.user_id.attribute.should.equal('required');
    });

    it('should require uri', function () {
      validation.errors.uri.attribute.should.equal('required');
    });

    it('should require secret', function () {
      validation.errors.secret.attribute.should.equal('required');
    });

    it('should have description', function () {
      Resource.schema.description.should.be.an('object');
    });

  });


  describe('registration', function () {

    before(function (done) {
      Resource.backend.reset();
      Resource.register(validResource, function (err, instance) {
        resource = instance;
        done();
      });
    });

    it('should generate a secret', function () {
      resource.secret.should.be.defined;
    });

  });

});