# Test dependencies
cwd       = process.cwd()
path      = require 'path'
Faker     = require 'Faker'
chai      = require 'chai'
async     = require 'async'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect



chai.use sinonChai
chai.should()




Modinha   = require 'modinha'
Scope     = require path.join(cwd, 'models/Scope')  




redis   = require('redis')
client  = redis.createClient()
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype
Scope.__client = client



describe 'Scope', ->


  {data,scopes,jsonScopes,err,instance,instances,scope,validation,update,deleted,urls} = {}


  before ->
    data = []
    for i in [0..9]
      data.push
        url: "https://#{Faker.Internet.domainName()}"
        serviceId: Modinha.defaults.uuid()
        description: Faker.Lorem.words(5).join(' ')

    scopes = Scope.initialize(data)
    jsonScopes = scopes.map (s) -> Scope.serialize(s)
    urls = scopes.map (s) -> s.url




  describe 'schema', ->

    beforeEach ->
      scope = new Scope { url: 'wrong' }
      validation = scope.validate()

    it 'should have a url', ->
      Scope.schema.url.type.should.equal 'string'

    it 'should use url as unique identifier', ->
      Scope.schema.url.uniqueId.should.be.true

    it 'should require a url', ->
      Scope.schema.url.required.should.be.true

    it 'should require url to be a valid url', ->
      validation.errors.url.attribute.should.equal 'format'

    it 'should have a description', ->
      Scope.schema.description.type.should.equal 'string'

    it 'should require a description', ->
      validation.errors.description.attribute.should.equal 'required'

    it 'should have a service id', ->
      Scope.schema.serviceId.should.be.an.object

    it 'should have "created" timestamp', ->
      Scope.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Scope.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonScopes
        Scope.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'scopes:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Scope

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonScopes
        Scope.list { index: 'scopes:modified' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'scopes:modified'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Scope


    describe 'with paging', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonScopes
        Scope.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'scopes:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Scope


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Scope.list { page: 2, size: 3 }, (error, results) ->
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




  describe 'get', ->

    describe 'by string', ->

      before (done) ->
        scope = scopes[0]
        json = jsonScopes[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Scope.get scopes[0].url, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Scope

      it 'should not initialize private properties', ->
        expect(instance.secret).to.be.undefined


    describe 'by string not found', ->

      before (done) ->
        Scope.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonScopes
        Scope.get urls, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Scope

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.secret).to.be.undefined


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        Scope.get [], (error, results) ->
          err = error
          instances = results
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an empty array', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0     




  describe 'insert', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Scope, 'index'
        sinon.stub(Scope, 'enforceUnique').callsArgWith(1, null)

        Scope.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Scope.index.restore()
        Scope.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Scope

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should store the serialized instance by url', ->
        multi.hset.should.have.been.calledWith 'scopes', instance.url, Scope.serialize(instance)

      it 'should index the instance', ->
        Scope.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Scope, 'index'

        Scope.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        Scope.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Scope.index.should.not.have.been.called




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        scope = scopes[0]
        json = jsonScopes[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Scope, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          url: scope.url
          serviceId: scope.serviceId
          description: 'updated'
          created: scope.created
          modified: scope.modified

        Scope.replace scope.url, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Scope.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Scope

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should replace the existing instance', ->
        expect(instance.description).to.equal 'updated'

      it 'should reindex the instance', ->
        Scope.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(scope)


    describe 'with unknown scope', ->

      before (done) ->
        sinon.stub(Scope, 'get').callsArgWith(2, null, null)
        Scope.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Scope.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'with invalid data', ->

      before (done) ->
        scope = scopes[0]

        Scope.replace scope.url, { description: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'patch', ->

    describe 'with valid data', ->

      before (done) ->
        scope = scopes[0]
        json = jsonScopes[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Scope, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          description: 'updated'


        Scope.patch scope.url, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Scope.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Scope

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'scopes', instance.url, sinon.match('"description":"updated"')

      it 'should reindex the instance', ->
        Scope.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(scopes[0])


    describe 'with unknown scope', ->

      before (done) ->
        sinon.stub(Scope, 'get').callsArgWith(2, null, null)
        Scope.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Scope.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null 


    describe 'with invalid data', ->

      before (done) ->
        scope = scopes[0]
        json = jsonScopes[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Scope.patch scope.url, { description: -1 }, (error, result) ->
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




  describe 'delete', ->

    describe 'by string', ->

      before (done) ->
        scope = scopes[0]
        sinon.spy Scope, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Scope, 'get').callsArgWith(2, null, scope)
        Scope.delete scope.url, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Scope.deindex.restore()
        Scope.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'scopes', scope.url

      it 'should deindex the instance', ->
        Scope.deindex.should.have.been.calledWith sinon.match.object, sinon.match(scope)


    describe 'with unknown scope', ->

      before (done) ->
        sinon.stub(Scope, 'get').callsArgWith(2, null, null)
        Scope.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Scope.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Scope, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Scope, 'get').callsArgWith(2, null, scopes)
        Scope.delete urls, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Scope.deindex.restore()
        Scope.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'scopes', urls

      it 'should deindex each instance', ->
        scopes.forEach (doc) ->
          Scope.deindex.should.have.been.calledWith sinon.match.object, doc
