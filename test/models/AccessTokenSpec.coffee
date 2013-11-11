# Test dependencies
cwd         = process.cwd()
path        = require 'path'
chai        = require 'chai'
async       = require 'async'
sinon       = require 'sinon'
sinonChai   = require 'sinon-chai'
Modinha     = require 'modinha'
AccessToken = require path.join(cwd, 'models/AccessToken')  
expect      = chai.expect




redis       = require 'redis'
multi       = redis.Multi.prototype
rclient     = redis.RedisClient.prototype




chai.use sinonChai
chai.should()




# AccessToken model
#
# The OAuth 2.0 Authorization Framework
#
# http://tools.ietf.org/html/rfc6749#section-1.4
# http://tools.ietf.org/html/rfc6749#section-3.3
# http://tools.ietf.org/html/rfc6749#section-6
# http://tools.ietf.org/html/rfc6749#section-7.1
# http://tools.ietf.org/html/rfc6749#section-10.3

describe 'AccessToken', ->

  {app,token,validation,err} = {}

  validToken =
    appId: '123'
    accountId: '456'




  beforeEach ->
    sinon.spy multi, 'hset'
    sinon.spy multi, 'zadd'

  afterEach ->
    multi.hset.restore()
    multi.zadd.restore()




  describe 'schema', ->

    before ->
      token = new AccessToken
      validation = token.validate()

    it 'should require access token', ->
      AccessToken.schema.accessToken.required.should.be.true

    it 'should generate a random string for access token', ->
      token.accessToken.should.be.a.string

    it 'should use access token as unique id', ->
      AccessToken.uniqueId.should.equal 'accessToken'
    
    it 'should have a token type', ->
      AccessToken.schema.tokenType.type.should.equal 'string'

    it 'should enumerate token types', ->
      AccessToken.schema.tokenType.enum.should.contain 'bearer'
      AccessToken.schema.tokenType.enum.should.contain 'mac'

    it 'should have a default token type of "bearer"', ->
      token.tokenType.should.equal 'bearer'

    it 'should require an app id', ->
      validation.errors.appId.attribute.should.equal 'required'

    it 'should require an account id', ->
      validation.errors.accountId.attribute.should.equal 'required'

    it 'should have an expiration'
    it 'should have a refresh token'
    
    it 'should have scope', ->
      AccessToken.schema.scope.type.should.equal 'string'

    it 'may define a default scope'
    it 'should have state?'
    it 'should have a "created" timestamp'




  describe 'creation', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        AccessToken.create validToken, (error, result) ->
          err = error
          token = result
          done()

      it 'should provide a null value', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(token).to.be.instanceof AccessToken

      it 'should set private properties', (done) ->
        sinon.spy AccessToken, 'initialize'
        AccessToken.create validToken, ->
          AccessToken.initialize.should.have.been.calledWith validToken, { private: true }
          AccessToken.initialize.restore()
          done()

      it 'should store the instance in a hash by accessToken as JSON', ->
        multi.hset.should.have.been.calledWith 'tokens', token.accessToken, AccessToken.serialize(token)

      it 'should add accessToken to a primary index', ->
        multi.zadd.should.have.been.calledWith 'tokens:accessToken', token.created, token.accessToken


    describe 'with invalid data', ->

      before (done) ->
        AccessToken.create {}, (error, result) ->
          err = error
          token = result
          done()

      it 'should provide a ValidationError', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(token).to.be.undefined




  describe 'issuance', ->

    beforeEach (done) ->
      app     = { _id: 'app' }
      account = { _id: 'account' }
      options = { scope: 'urls' }

      AccessToken.issue app, account, options, (error, instance) ->
        err = error
        token = instance
        done()

    it 'should provide a null error', ->
      expect(err).to.be.null

    it 'should provide an AccessToken instance', ->
      expect(token).to.be.instanceof AccessToken

    it 'should store the token', ->
      multi.hset.should.have.been.calledWith 'tokens', token.accessToken, AccessToken.serialize(token)
      multi.zadd.should.have.been.calledWith 'tokens:accessToken', token.created, token.accessToken

    it 'should set the app id', ->
      token.appId.should.equal 'app'

    it 'should set the user id', ->
      token.accountId.should.equal 'account'

    it 'should generate an access token', ->
      token.accessToken.should.be.a.string

    it 'should set an expiration'

    it 'should generate a refresh token'

    it 'should set scope', ->
      token.scope.should.equal 'urls'

    it 'should invalidate/destroy previously issued access tokens for this user/app?'




  describe 'verification', ->




    describe 'with valid details', ->

      it 'should provide a null error'
      it 'should provide the token'

    describe 'with unknown access token', ->

      it 'should provide an "InvalidTokenError"'
      it 'should not provide verification'

    describe 'with expired access token', ->

      it 'should provide an "InvalidTokenError"'
      it 'should not provide verification'

    describe 'with insufficient scope', ->

      it 'should provide an "InsufficientScopeError"'
      it 'should not provide verification'

    describe 'with omitted scope', ->

      it 'should provide an "InsufficientScopeError"'
      it 'should not provide verification'

    describe 'with omitted scope and defined default', ->
