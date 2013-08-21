/**
 * Test dependencies
 */

var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , User = require(path.join(cwd, 'models/User')) 
  , Client = require(path.join(cwd, 'models/Client'))   
  , AccessToken = require(path.join(cwd, 'models/AccessToken'))
  , expect = chai.expect
  ;

/**
 * AccessToken model
 *
 * The OAuth 2.0 Authorization Framework
 *
 * http://tools.ietf.org/html/rfc6749#section-1.4
 * http://tools.ietf.org/html/rfc6749#section-3.3
 * http://tools.ietf.org/html/rfc6749#section-6
 * http://tools.ietf.org/html/rfc6749#section-7.1
 * http://tools.ietf.org/html/rfc6749#section-10.3
 */

describe('AccessToken', function () {

  var user, validUser = {
    _id: '1234',
    first: 'John',
    last: 'Coltrane',
    username: 'trane',
    email: 'trane@example.com',
    password: 'secret'    
  };

  var client, validClient = {
    _id: '2345',
    user_id: validUser._id,
    type: 'confidential',
    name: 'ThirdPartyApp',
    redirect_uris: 'http://example.com/callback.html'    
  };

  var err, token, validation, validToken = {
    client_id: validClient._id,
    user_id: validUser._id,
    access_token: '1234abcd',
    expires_at: new Date('2014/01/31'),
    refresh_token: '3456asdf',
    scope: 'https://api1.tld https://api2.tld'
  };


  beforeEach(function () { 
    AccessToken.backend.reset(); 
  });


  describe('schema', function () {

    beforeEach(function () {
      token = new AccessToken();
      validation = token.validate();
    });

    it('should require a client id', function () {
      validation.errors.client_id.attribute.should.equal('required');
    });

    it('should require a user id', function () {
      validation.errors.user_id.attribute.should.equal('required');
    });

    it('should have an access token', function () {
      AccessToken.schema.access_token.type.should.equal('string');
    });

    it('should have a token type', function () {
      AccessToken.schema.token_type.type.should.equal('string');
    });

    it('should enumerate token types', function () {
      AccessToken.schema.token_type.enum.should.contain('bearer');
      AccessToken.schema.token_type.enum.should.contain('mac');
    });

    it('should default token type to "bearer"', function () {
      token.token_type.should.equal('bearer');
    });

    it('should have an expiration', function () {
      AccessToken.schema.expires_at.type.should.equal('any');
    });

    it('should have a refresh token', function () {
      AccessToken.schema.refresh_token.type.should.equal('string');
    });

    it('should have scope', function () {
      AccessToken.schema.scope.type.should.equal('string');
    });

    it('may define a default scope');
    
    it('should have state??');

    it('should have "created" timestamp', function () {
      AccessToken.schema.created.should.be.an('object');
    });
    
    it('should have "modified" timestamp', function () {
      AccessToken.schema.modified.should.be.an('object');
    });

  });


  describe('constructor', function () {

    it('should set attrs defined in schema', function () {
      token = new AccessToken(validToken);
      token.client_id.should.equal(validToken.client_id);
      token.access_token.should.equal(validToken.access_token);
      token.expires_at.should.equal(validToken.expires_at);
      token.refresh_token.should.equal(validToken.refresh_token);
      token.scope.should.equal(validToken.scope);
    });
    
    it('should ignore attrs not defined in schema', function () {
      token = new AccessToken({ hacker: 'p0wn3d' });
      expect(token.hacker).equals(undefined);
    });

  });


  describe('creation', function () {

    describe('with valid data', function () {

      before(function (done) {
        AccessToken.create(validToken, function (error, instance) {
          err = error; 
          token = instance; 
          done();
        });
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      });

      it('should provide an AccessToken instance', function () {
        (token instanceof AccessToken).should.equal(true);
      });      

      it('should generate an access_token');

      it('should set the "created" timestamp', function () {
        token.created.should.be.defined;
      });

      it('should set the "modified" timestamp', function () {
        token.modified.should.be.defined;
      });

    });

    describe('with invalid data', function () {

      beforeEach(function (done) {
        AccessToken.create({}, function (error, instance) {
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

    describe('by access token', function () {

      before(function (done) {
        AccessToken.create(validToken, function (e) {
          AccessToken.find({ access_token: validToken.access_token }, function (error, instance) {
            err = error;
            token = instance;
            done();
          });
        });        
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      })

      it('should provide an AccessToken instance', function () {
        (token instanceof AccessToken).should.equal(true);
      });

    });

  });


  describe('issuance', function () {

    beforeEach(function (done) {
      Client.backend.reset();
      User.backend.reset();
      AccessToken.backend.reset();

      User.create(validUser, function (err, instance) {
        user = instance;
        Client.register(validClient, function (err, instance) {
          client = instance;
          AccessToken.issue(client, user, { scope: 'http://test.tld' }, function (error, instance) {
            err = error;
            token = instance;
            done();
          });
        });
      });
    });

    it('should provide a null error', function () {
      expect(err).equals(null);
    });

    it('should provide an AccessToken instance', function () {
      (token instanceof AccessToken).should.equal(true);
    });

    it('should save the instance', function () {
      AccessToken.backend.documents[0].should.equal(token);
    });

    it('should set the client_id', function () {
      token.client_id.should.equal(client._id);
    });

    it('should set the user_id', function () {
      token.user_id.should.equal(user._id);
    });

    it('should generate an access_token', function () {
      token.access_token.should.be.defined;
    });

    it('should set an expiration', function () {
      token.expires_at.should.be.defined;
    });

    it('should generate a refresh_token', function () {
      token.refresh_token.should.be.defined;
    });

    it('should set scope', function () {
      token.scope.should.equal('http://test.tld');
    });

  });


  describe('verification', function () {
    
    var verified;

    beforeEach(function (done) {
      Client.backend.reset();
      User.backend.reset();
      AccessToken.backend.reset();

      User.create(validUser, function (err, instance) {
        user = instance;
        Client.create(validClient, function (err, instance) {
          client = instance;
          AccessToken.issue(client, user, { scope: 'http://test.tld' }, function (error, instance) {
            err = error;
            token = instance;
            done();
          });
        });
      });
    });    


    describe('with valid details', function () {

      before(function (done) {
        AccessToken.verify(token.access_token, client._id, token.scope, function (err, truth) {
          verified = truth;
          done();
        });
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      })

      it('should provide verification', function () {
        expect(verified).equals(true);
      });

    });


    describe('with mismatching client', function () {

      before(function (done) {
        AccessToken.verify(token.access_token, 'wrong', token.scope, function (error, truth) {
          err = error;
          verified = truth;
          done();
        });
      });

      it('should provide an "InvalidTokenError"', function () {
        err.name.should.equal('InvalidTokenError');
      });

      it('should not provide verification', function () {
        expect(verified).equals(undefined);
      });

    });


    describe('with unknown access token', function () {

      before(function (done) {
        AccessToken.verify('unknown', client._id, token.scope, function (error, truth) {
          err = error;
          verified = truth;
          done();
        });
      });

      it('should provide an "InvalidTokenError"', function () {
        err.name.should.equal('InvalidTokenError');
      });

      it('should not provide verification', function () {
        expect(verified).equals(undefined);
      });

    });


    describe('with expired access token', function () {

      before(function (done) {
        AccessToken.create({
          client_id: token.client_id,
          user_id: token.user_id,
          access_token: '1234abcd',
          expires_at: new Date('2012/12/21'),
          refresh_token: '3456asdf',
          scope: 'https://api1.tld https://api2.tld'
        }, function (err, instance) {
          AccessToken.verify(instance.access_token, instance.client_id, instance.scope, function (error, truth) {
            err = error;
            verified = truth;
            done();
          });
        });
      });

      it('should provide an "InvalidTokenError"', function () {
        err.name.should.equal('InvalidTokenError');
      });

      it('should not provide verification', function () {
        expect(verified).equals(undefined);
      });

    });


    describe('with insufficient scope', function () {

      before(function (done) {
        AccessToken.verify(token.access_token, client._id, 'https://insufficient.tld', function (error, truth) {
          err = error;
          verified = truth;
          done();
        });
      });

      it('should provide an "InsufficientScopeError"', function () {
        err.name.should.equal('InsufficientScopeError');
      });

      it('should not provide verification', function () {
        expect(verified).equals(undefined);
      });

    });
    

    describe('with omitted scope', function () {

      before(function (done) {
        AccessToken.verify(token.access_token, client._id, undefined, function (err, truth) {
          verified = truth;
          done();
        });
      });

      it('should provide an "InsufficientScopeError"', function () {
        err.name.should.equal('InsufficientScopeError');
      });

      it('should not provide verification', function () {
        expect(verified).equals(undefined);
      });

    });


    describe('with omitted scope and defined default', function () {});

  });

});