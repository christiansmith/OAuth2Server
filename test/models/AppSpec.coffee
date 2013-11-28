# Test dependencies
cwd       = process.cwd()
path      = require 'path'
Faker     = require 'Faker'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




# Configure Chai and Sinon
chai.use sinonChai
chai.should()




# Code under test
Modinha     = require 'modinha'
App         = require path.join(cwd, 'models/App')
Credentials = require path.join(cwd, 'models/Credentials')




# Redis lib for spying and stubbing
redis   = App.__redis
client  = App.__client
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype




describe 'App', ->


  {data,app,apps,jsonApps,credentials} = {}
  {err,validation,instance,instances,update,deleted,original,ids} = {}
  

  before ->

    # Mock data
    data = []

    for i in [0..9]
      data.push
        type: 'confidential'
        name: 'ThirdPartyApp'
        key: Faker.random.number(10).toString()
        redirect_uri: "https://#{Faker.Internet.domainName()}/callback"

    apps = App.initialize(data, { private: true })
    jsonApps = apps.map (d) -> 
      App.serialize(d)
    ids = apps.map (d) ->
      d._id




  describe 'schema', ->

    before ->
      app = new App
      validation = app.validate()

    it 'should have unique identifier', ->
      App.schema[App.uniqueId].should.be.an.object

    it 'should generate a uuid for unique id', ->
      App.schema._id.default.should.equal Modinha.defaults.uuid

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
      App.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      App.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonApps
        App.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'apps:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof App

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.key).to.be.undefined

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonApps
        App.list { index: 'apps:secondary:value' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'apps:secondary:value'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10      
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof App

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.key).to.be.undefined


    describe 'with paging', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonApps
        App.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'apps:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10        
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof App


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        App.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.zrevrange.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an empty list', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0


    describe 'with private option', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonApps
        App.list { private: true }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof App

      it 'should intialize private properties', ->
        instances.forEach (instance) ->
          instance.key.should.be.defined




  describe 'get', ->

    describe 'by string', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        App.get app._id, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof App

      it 'should not initialize private properties', ->
        expect(instance.key).to.be.undefined


    describe 'by string not found', ->

      before (done) ->
        App.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonApps
        App.get ids, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10        
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof App

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.key).to.be.undefined


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        App.get [], (error, results) ->
          err = error
          instances = results
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an empty array', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0


    describe 'with private option', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        App.get app._id, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof App

      it 'should not initialize private properties', ->
        instance.key.should.be.defined





  describe 'insert', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        credentials = new Credentials role: 'app'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy App, 'index'
        sinon.stub(App, 'enforceUnique').callsArgWith(1, null)
        sinon.stub(Credentials, 'insert').callsArgWith(1, null, credentials)

        App.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        App.index.restore()
        App.enforceUnique.restore()
        Credentials.insert.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof App

      it 'should store the serialized instance by unique id', ->
        multi.hset.should.have.been.calledWith 'apps', instance._id, sinon.match('"redirect_uri":"' + instance.redirect_uri)

      it 'should index the instance', ->
        App.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)

      it 'should issue credentials', ->
        Credentials.insert.should.have.been.calledWith { role: 'app' }

      it 'should associate credentials with app', ->
        instance.key.should.be.a.string

      it 'should provide the secret with the created instance', ->
        instance.secret.should.be.a.string

      it 'should not store the secret', ->
        multi.hset.should.not.have.been.calledWith 'apps', instance._id, sinon.match('"secret":"' + instance.secret + '"')


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy App, 'index'

        App.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        App.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        App.index.should.not.have.been.called


    describe 'with private values option', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy App, 'index'
        sinon.stub(App, 'enforceUnique').callsArgWith(2, null)

        App.insert data[0], { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        App.index.restore()
        App.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof App

      it 'should provide private properties', ->
        instance.key.should.be.defined




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        app = apps[0]

        sinon.stub(App, 'get').callsArgWith(2, null, app)
        sinon.spy App, 'reindex'

        update =
          _id: app._id
          type: 'public'
          redirect_uri: "https://#{Faker.Internet.domainName()}"
          key: app.key

        App.replace app._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        App.get.restore()
        App.reindex.restore()


      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof App

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should replace the existing instance', ->
        expect(instance.type).to.equal 'public'

      it 'should reindex the instance', ->
        App.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), app


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(2, null, null)
        App.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        App.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'with invalid data', ->

      before (done) ->
        app = apps[0]

        App.replace app._id, { type: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'with private values option', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy App, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: app._id
          type: 'trusted'
          key: 'updatedkey'

        App.replace app._id, update, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        App.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof App

      it 'should provide private properties', ->
        expect(instance.key).to.equal 'updatedkey'




  describe 'patch', ->

    describe 'with valid data', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy App, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: app._id
          type: 'trusted'


        App.patch app._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        App.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof App

      it 'should not provide private properties', ->
        expect(instance.key).to.be.undefined

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'apps', instance._id, sinon.match('"type":"trusted"')

      it 'should reindex the instance', ->
        App.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(app)


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(2, null, null)
        App.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        App.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null 


    describe 'with invalid data', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        App.patch app._id, { type: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'with private values option', ->

      before (done) ->
        app = apps[0]
        json = jsonApps[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy App, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: app._id
          description: 'updated'

        App.patch app._id, update, { private:true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        App.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof App

      it 'should provide private properties', ->
        instance.key.should.be.a.string




  describe 'delete', ->

    describe 'by string', ->

      before (done) ->
        instance = apps[0]
        sinon.spy App, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(App, 'get').callsArgWith(2, null, instance)
        App.delete instance._id, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        App.deindex.restore()
        App.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'apps', instance._id

      it 'should deindex the instance', ->
        App.deindex.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(2, null, null)
        App.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        App.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy App, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(App, 'get').callsArgWith(2, null, apps)
        App.delete ids, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        App.deindex.restore()
        App.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'apps', ids

      it 'should deindex each instance', ->
        apps.forEach (doc) ->
          App.deindex.should.have.been.calledWith sinon.match.object, doc



