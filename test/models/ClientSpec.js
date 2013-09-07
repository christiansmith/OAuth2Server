/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , Client = require(path.join(cwd, 'models/Client'))
  , expect = chai.expect
  ;

/**
 * Client model
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-2
 */

describe('Client', function () {

  var user, validUser = {
    _id: '1234',
    email: 'trane@example.com',
    password: 'secret'
  };

  var err, client, validation, validClient = {
    _id: '2345',
    user_id: validUser._id,
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'
  };


  beforeEach(function () {
    Client.backend.reset(); 
  });


  describe('schema', function () {

    beforeEach(function () {
      client = new Client({});
      validation = client.validate();
    });

    it('should have _id', function () {
      Client.schema._id.should.be.an('object');
    });

    it('should require user_id', function () {
      validation.errors.user_id.attribute.should.equal('required');
    });

    it('should require type', function () {
      validation.errors.type.attribute.should.equal('required');
    });

    it('should enumerate types', function () {
      Client.schema.type.enum.should.contain('confidential');
      Client.schema.type.enum.should.contain('public');
    });

    it('should have name', function () {
      Client.schema.name.type.should.equal('string');
    });

    it('should have website', function () {
      Client.schema.website.type.should.equal('string');
    });

    it('should have description', function () {
      Client.schema.description.type.should.equal('string');
    });

    it('should have logo image', function () {
      Client.schema.logo.type.should.equal('string');
    });

    it('should have terms accepted', function () {
      Client.schema.terms.type.should.equal('boolean');
    });

    it('should have secret', function () {
      Client.schema.secret.type.should.equal('string');
    });

    it('should have redirect uris');

    it('should have "created" timestamp', function () {
      Client.schema.created.should.be.an('object');
    });
    
    it('should have "modified" timestamp', function () {
      Client.schema.modified.should.be.an('object');
    });

  });


  describe('creation', function () {

    before(function (done) {
      Client.backend.reset();
      Client.create(validClient, function (err, instance) {
        client = instance;
        done();
      });
    });

    it('should generate a secret', function () {
      client.secret.should.be.defined;
    });

  });


  describe('secret verification', function () {
    it('should verify a correct secret');
    it('should not verify an incorrect secret');
  });


  describe('authentication', function () {
    it('should authenticate a valid set of credentials');
    it('should not authenticate an invalid secret');
    it('should not authenticate an unknown client');
  });

});