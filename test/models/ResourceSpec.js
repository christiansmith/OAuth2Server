/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , User = require(path.join(cwd, 'models/User'))  
  , Resource = require(path.join(cwd, 'models/Resource'))
  , Credentials = require(path.join(cwd, 'models/HTTPCredentials')) 
  , expect = chai.expect
  ;


/**
 * Specs
 */

describe('Resource', function () {

  var err, resource, validation, validResource = {
    uri: 'https://protected.tld',
    scopes: [
      { 'https://protected.tld/': 'Read/write access to the entire service.'}
    ]
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

    it('should require uri', function () {
      validation.errors.uri.attribute.should.equal('required');
    });

    it('should have scopes', function () {
      Resource.schema.scopes.type.should.equal('array');
    });

    it('should require scopes', function () {
      validation.errors.scopes.attribute.should.equal('required');
    });

    it('should have a private "key" reference to credentials', function () {
      Resource.schema.key.private.should.equal(true);
    });

//    it('should have secret', function () {
//      Resource.schema.secret.should.be.an('object');
//    });

    it('should have description', function () {
      Resource.schema.description.should.be.an('object');
    });

  });


  describe('creation', function () {

    var credentials;

    before(function (done) {
      Resource.backend.reset();
      Credentials.backend.reset();
      Resource.create(validResource, function (err, instance) {
        resource = instance;
        credentials = Credentials.backend.documents[0]
        done();
      });
    });

    it('should issue HTTP credentials', function () {
      Credentials.backend.documents[0].role.should.equal('resource');
    });

    it('should associate credentials with the resource', function () {
      resource.key.should.equal(Credentials.backend.documents[0].key);
    });

    it('should provide the secret with the resource', function () {
      resource.secret.should.equal(credentials.secret)
    });

  });

});