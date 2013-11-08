# Test dependencies
cwd       = process.cwd()
path      = require 'path'
chai      = require 'chai'
async     = require 'async'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
Scope     = require path.join(cwd, 'models/Scope')  
expect    = chai.expect



redis     = require 'redis'
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype



chai.use sinonChai
chai.should()


describe 'Scope', ->



  {err,scope,validation} = {}



  beforeEach ->
    sinon.spy rclient, 'hset'

  afterEach ->
    rclient.hset.restore()



  describe 'schema', ->

    beforeEach ->
      scope = new Scope { url: 'wrong' }
      validation = scope.validate()

    it 'should have a url', ->
      Scope.schema.url.type.should.equal 'string'

    it 'should require a url', ->
      Scope.schema.url.required.should.equal true

    it 'should require url to be a valid url', ->
      validation.errors.url.attribute.should.equal 'format'

    it 'should have a description', ->
      Scope.schema.description.type.should.equal 'string'

    it 'should require a description', ->
      validation.errors.description.attribute.should.equal 'required'



  describe 'creation', ->


    describe 'with valid data', ->

      beforeEach (done) -> 
        data =
          url: 'https://service.tld/resource'
          description: 'operate on the resource'

        Scope.set data, (error, instance) ->
          err = error
          scope = instance
          done()

      it 'should provide the callback a null error', ->
        expect(err).equals null

      it 'should provide the callback a scope instance', ->
        expect(scope instanceof Scope).equals true

      it 'should store the scope', ->
        rclient.hset.should.have.been.calledWith 'scopes', scope.url, JSON.stringify(scope)


    describe 'with invalid data', ->

      beforeEach (done) ->
        Scope.set {}, (error, instance) ->
          err = error
          scope = instance
          done()  

      it 'should provide the callback a validation error', ->
        err.message.should.equal 'Validation error.'    

      it 'should not provide a scope instance', ->
        expect(scope).equals undefined



  describe 'retrieval', ->

    scopes = [
      { url: 'https://api.tld/resource1', description: 'access stuff at this url' }
      { url: 'https://api.tld/resource2', description: 'access other stuff' }
    ]

    setter = (scope, callback) ->
      Scope.set scope, (err) ->
        if err then return callback err
        callback()

    before (done) ->
      async.each scopes, setter, done

    it 'should get a scope by url', ->
      Scope.get scopes[0].url, (err, result) ->
        result.description.should.equal scopes[0].description

    it 'should get a list of scopes by url', ->
      Scope.get [scopes[0].url, scopes[1].url], (err, result) ->
        result[0].description.should.equal scopes[0].description
        result[1].description.should.equal scopes[1].description

    it 'should get scopes by role'
    it 'should get scopes by service'


