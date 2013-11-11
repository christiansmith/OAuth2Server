cwd       = process.cwd()
path      = require 'path'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




Modinha = require 'modinha'
Credentials = require path.join(cwd, 'models/Credentials')




redis     = require 'redis'
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'Credentials', ->




  {credentials,validation,err} = {}




  beforeEach (done) ->
    sinon.spy multi, 'hset'
    sinon.spy multi, 'zadd'
    done()

  afterEach ->
    multi.hset.restore()
    multi.zadd.restore()




  describe 'schema', ->

    before ->
      credentials = new Credentials
      validation = credentials.validate()

    it 'should require key', ->
      Credentials.schema.key.required.should.be.true

    it 'should generate a random string for key', ->
      credentials.key.should.be.a.string

    it 'should require secret', ->
      Credentials.schema.secret.required.should.be.true

    it 'should generate a random string for secret', ->
      credentials.secret.should.be.a.string

    it 'should require role', ->
      validation.errors.role.attribute.should.equal 'required'

    it 'should enumerate roles', ->
      Credentials.schema.role.enum.should.contain 'app'
      Credentials.schema.role.enum.should.contain 'service'
      Credentials.schema.role.enum.should.contain 'admin'




  describe 'creation', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        Credentials.create { role: 'app' }, (error, instance) ->
          err = error
          credentials = instance
          done()

      it 'should provide a null value', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(credentials).to.be.instanceof Credentials

      it 'should set private properties', (done) ->
        sinon.spy Credentials, 'initialize'
        Credentials.create { role: 'app' }, ->
          Credentials.initialize.should.have.been.calledWith { role: 'app' }
          Credentials.initialize.restore()
          done()

      it 'should store the instance in a hash by key as JSON', ->
        multi.hset.should.have.been.calledWith 'credentials', credentials.key, Credentials.serialize(credentials)

      it 'should add key to a primary index', ->
        multi.zadd.should.have.been.calledWith 'credentials:key', credentials.created, credentials.key





