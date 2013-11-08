cwd       = process.cwd()
path      = require 'path'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




Modinha     = require 'modinha'
App         = require path.join(cwd, 'models/App') 
Credentials = require path.join(cwd, 'models/Credentials') 




redis     = require 'redis'
client    = redis.createClient()
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'App', ->


  {app,validation,err} = {}

  validApp =
    type: 'confidential'
    name: 'ThirdPartyApp'
    redirect_uri: 'https://app.tld/callback'




  describe 'schema', ->

    before ->
      app = new App
      validation = app.validate()

    it 'should have a unique id', ->
      App.schema._id.type.should.equal 'string'

    it 'should generate a uuid for unique id', ->
      App.schema._id.default.should.equal Modinha.defaults.uuid
    
    it 'should require unique id to be valid uuid', ->
      App.schema._id.format.should.equal 'uuid'

    it 'should require type', ->
      validation.errors.type.attribute.should.equal 'required'

    it 'should enumerate types', ->
      App.schema.type.enum.should.contain 'confidential'
      App.schema.type.enum.should.contain 'public'
      App.schema.type.enum.should.contain 'trusted'

    it 'should have name', ->
      App.schema.name.type.should.be.a.string

    it 'should have website', ->
      App.schema.website.type.should.be.a.string

    it 'should have description', ->
      App.schema.description.type.should.be.a.string

    it 'should have logo image', ->
      App.schema.logo.type.should.be.a.string

    it 'should have terms accepted', ->
      App.schema.terms.type.should.be.boolean

    it 'should have redirect uri', ->
      App.schema.redirect_uri.type.should.be.a.string

    it 'should have reference to credentials', ->
      App.schema.key.should.be.a.string

    it 'should protect reference to credentials as private', ->
      App.schema.key.private.should.be.true

    it 'should have "created" timestamp', ->
      App.schema.created.should.be.an.object

    it 'should have "modified" timestamp', ->
      App.schema.modified.should.be.an.object




  describe 'creation', ->

    beforeEach (done) ->
      sinon.spy multi, 'hset'
      sinon.spy multi, 'zadd'
      sinon.stub(Credentials, 'create').callsArgWith(1, null, new Credentials { role: 'app' })
      done()
      #client.flushdb done

    afterEach ->
      multi.hset.restore()
      multi.zadd.restore()
      Credentials.create.restore()

    describe 'with valid data', ->

      beforeEach (done) ->
        App.create validApp, (error, instance) ->
          err = error
          app = instance
          done()

      it 'should provide a null value', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(app).to.be.instanceof App

      it 'should set private properties', (done) ->
        sinon.spy App, 'initialize'
        App.create validApp, ->
          App.initialize.should.have.been.calledWith validApp, { private: true }
          App.initialize.restore()
          done()

      it 'should store the app in a hash by _id as JSON', ->
        multi.hset.should.have.been.calledWith 'apps', app._id, sinon.match('"_id":"' + app._id + '"')

      it 'should add _id to a primary index', ->
        multi.zadd.should.have.been.calledWith 'apps:_id', app.created, app._id

      it 'should issue HTTP credentials', ->
        Credentials.create.should.have.been.calledWith { role: 'app' }

      it 'should associate credentials with app', ->
        app.key.should.be.a.string

      it 'should provide the secret with the created instance', ->
        app.secret.should.be.a.string

      it 'should not store the secret', ->
        multi.hset.should.not.have.been.calledWith 'apps', app._id, sinon.match('"secret":"' + app.secret + '"')

