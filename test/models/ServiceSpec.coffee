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
Service     = require path.join(cwd, 'models/Service')
Credentials = require path.join(cwd, 'models/Credentials')




# Redis lib for spying and stubbing
redis   = Service.__redis
client  = Service.__client
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype




describe 'Service', ->


  {data,service,services,jsonServices,credentials} = {}
  {err,validation,instance,instances,update,deleted,original,ids} = {}
  

  before ->

    # Mock data
    data = []

    for i in [0..9]
      data.push
        uri: "https://#{Faker.Internet.domainName()}"
        key: Faker.random.number(100).toString()
        description: Faker.Lorem.words(5).join(' ')

    services = Service.initialize(data, { private: true })
    jsonServices = services.map (d) -> 
      Service.serialize(d)
    ids = services.map (d) ->
      d._id




  describe 'schema', ->

    before ->
      service = new Service
      validation = service.validate()

    it 'should have unique identifier', ->
      Service.schema[Service.uniqueId].should.be.an.object

    it 'should generate a uuid for unique id', ->
      Service.schema._id.default.should.equal Modinha.defaults.uuid

    it 'should require uri', ->
      validation.errors.uri.attribute.should.equal 'required'

    it 'should have scope'

    it 'should have private key reference to credentials', ->
      Service.schema.key.private.should.be.true

    it 'should have a description', ->
      Service.schema.description.type.should.equal 'string'

    it 'should have "created" timestamp', ->
      Service.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Service.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonServices
        Service.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'services:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Service

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.key).to.be.undefined

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonServices
        Service.list { index: 'services:secondary:value' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'services:secondary:value'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10      
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Service

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.key).to.be.undefined


    describe 'with paging', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonServices
        Service.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'services:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10        
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Service


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Service.list { page: 2, size: 3 }, (error, results) ->
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
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonServices
        Service.list { private: true }, (error, results) ->
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
          expect(instance).to.be.instanceof Service

      it 'should intialize private properties', ->
        instances.forEach (instance) ->
          instance.key.should.be.defined




  describe 'get', ->

    describe 'by string', ->

      before (done) ->
        service = services[0]
        json = jsonServices[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Service.get service._id, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Service

      it 'should not initialize private properties', ->
        expect(instance.key).to.be.undefined


    describe 'by string not found', ->

      before (done) ->
        Service.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonServices
        Service.get ids, (error, results) ->
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
          expect(instance).to.be.instanceof Service

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
        Service.get [], (error, results) ->
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
        service = services[0]
        json = jsonServices[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Service.get service._id, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Service

      it 'should not initialize private properties', ->
        instance.key.should.be.defined





  describe 'insert', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        credentials = new Credentials role: 'service'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Service, 'index'
        sinon.stub(Service, 'enforceUnique').callsArgWith(1, null)
        sinon.stub(Credentials, 'insert').callsArgWith(1, null, credentials)

        Service.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Service.index.restore()
        Service.enforceUnique.restore()
        Credentials.insert.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Service

      it 'should store the serialized instance by unique id', ->
        multi.hset.should.have.been.calledWith 'services', instance._id, sinon.match('"uri":"' + instance.uri)

      it 'should index the instance', ->
        Service.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)

      it 'should issue credentials', ->
        Credentials.insert.should.have.been.calledWith { role: 'service' }

      it 'should associate credentials with service', ->
        instance.key.should.be.a.string

      it 'should provide the secret with the created instance', ->
        instance.secret.should.be.a.string

      it 'should not store the secret', ->
        multi.hset.should.not.have.been.calledWith 'services', instance._id, sinon.match('"secret":"' + instance.secret + '"')


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Service, 'index'

        Service.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        Service.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Service.index.should.not.have.been.called


    describe 'with private values option', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Service, 'index'
        sinon.stub(Service, 'enforceUnique').callsArgWith(2, null)

        Service.insert data[0], { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Service.index.restore()
        Service.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Service

      it 'should provide private properties', ->
        instance.key.should.be.defined




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        service = services[0]
        json = jsonServices[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Service, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: service._id
          uri: "https://#{Faker.Internet.domainName()}"
          description: 'updated'

        Service.replace service._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Service.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Service

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should replace the existing instance', ->
        expect(instance.description).to.equal 'updated'

      it 'should reindex the instance', ->
        Service.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), Service.initialize(service)


    describe 'with invalid data', ->

      before (done) ->
        service = services[0]

        Service.replace service._id, { description: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'with private values option', ->

      before (done) ->
        service = services[0]
        json = jsonServices[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Service, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: service._id
          uri: "https://#{Faker.Internet.domainName()}"
          description: 'updated'
          key: 'updatedkey'

        Service.replace service._id, update, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Service.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Service

      it 'should provide private properties', ->
        expect(instance.key).to.equal 'updatedkey'




  describe 'patch', ->

    describe 'with valid data', ->

      before (done) ->
        service = services[0]
        json = jsonServices[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Service, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: service._id
          description: 'updated'


        Service.patch service._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Service.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Service

      it 'should not provide private properties', ->
        expect(instance.key).to.be.undefined

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'services', instance._id, sinon.match('"description":"updated"')

      it 'should reindex the instance', ->
        Service.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(service)


    describe 'with invalid data', ->

      before (done) ->
        service = services[0]
        json = jsonServices[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Service.patch service._id, { description: -1 }, (error, result) ->
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
        service = services[0]
        json = jsonServices[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Service, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: service._id
          description: 'updated'

        Service.patch service._id, update, { private:true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Service.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Service

      it 'should provide private properties', ->
        instance.key.should.be.a.string




  describe 'delete', ->

    describe 'by string', ->

      before (done) ->
        instance = services[0]
        sinon.spy Service, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Service, 'get').callsArgWith(2, null, instance)
        Service.delete instance._id, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Service.deindex.restore()
        Service.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'services', instance._id

      it 'should deindex the instance', ->
        Service.deindex.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Service, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Service, 'get').callsArgWith(2, null, services)
        Service.delete ids, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Service.deindex.restore()
        Service.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'services', ids

      it 'should deindex each instance', ->
        services.forEach (doc) ->
          Service.deindex.should.have.been.calledWith sinon.match.object, doc



