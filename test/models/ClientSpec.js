/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , Client = require(path.join(cwd, 'models/Client'))
  , Credentials = require(path.join(cwd, 'models/HTTPCredentials'))  
  , expect = chai.expect
  ;

/**
 * Client model
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-2
 */

describe('Client', function () {


  var err, client, validation, validClient = {
    _id: '2345',
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

    it('should have redirect uris');

    it('should have a private "key" reference to credentials', function () {
      Client.schema.key.private.should.equal(true);
    })

    it('should have "created" timestamp', function () {
      Client.schema.created.should.be.an('object');
    });
    
    it('should have "modified" timestamp', function () {
      Client.schema.modified.should.be.an('object');
    });

  });


  describe('creation', function () {

    var credentials;

    before(function (done) {
      Client.backend.reset();
      Credentials.backend.reset();
      Client.create(validClient, function (err, instance) {
        client = instance;
        credentials = Credentials.backend.documents[0]
        done();
      });
    });

    it('should issue HTTP credentials', function () {
      Credentials.backend.documents[0].role.should.equal('client');
    });

    it('should associate credentials with the client', function () {
      client.key.should.equal(Credentials.backend.documents[0].key);
    });

    it('should provide the secret with the client', function () {
      client.secret.should.equal(credentials.secret)
    });

    // This works in practice but the memory backend still modifies
    // the instance. Change Modinha default backend to push an extended
    // new object into backend.documents.
    // 
    // it('should not store the secret', function () {
    //   expect(Client.backend.documents[0].secret).toEqual(undefined)
    // });

  });

});