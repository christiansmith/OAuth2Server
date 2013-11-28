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




Modinha     = require 'modinha'
Credentials = require path.join(cwd, 'models/Credentials')  




redis     = Credentials.__redis
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'Credentials', ->


  {data,credentials,jsonCredentials,err,instance,instances,credential,validation,update,deleted,keys} = {}


  before ->
    data = []
    for i in [0..9]
      data.push
        role: 'service'

    credentials = Credentials.initialize(data)
    jsonCredentials = credentials.map (s) -> Credentials.serialize(s)
    keys = credentials.map (s) -> s.key




  describe 'schema', ->

    beforeEach ->
      instance = new Credentials { url: 'wrong' }
      validation = instance.validate()

    it 'should require key', ->
      Credentials.schema.key.required.should.be.true

    it 'should generate a random string for key', ->
      instance.key.should.be.a.string

    it 'should require secret', ->
      Credentials.schema.secret.required.should.be.true

    it 'should generate a random string for secret', ->
      instance.secret.should.be.a.string

    it 'should require role', ->
      validation.errors.role.attribute.should.equal 'required'

    it 'should enumerate roles', ->
      Credentials.schema.role.enum.should.contain 'app'
      Credentials.schema.role.enum.should.contain 'service'
      Credentials.schema.role.enum.should.contain 'admin'

    it 'should have "created" timestamp', ->
      Credentials.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Credentials.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonCredentials
        Credentials.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'credentials:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Credentials

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonCredentials
        Credentials.list { index: 'credentials:modified' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'credentials:modified'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Credentials


    describe 'with paging', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonCredentials
        Credentials.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'credentials:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Credentials


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Credentials.list { page: 2, size: 3 }, (error, results) ->
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
        credential = credentials[0]
        json = jsonCredentials[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Credentials.get credential.key, (error, result) ->
          err = error
          instance = result

          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Credentials


    describe 'by string not found', ->

      before (done) ->
        Credentials.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonCredentials
        Credentials.get keys, (error, results) ->
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
          expect(instance).to.be.instanceof Credentials


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        Credentials.get [], (error, results) ->
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
        sinon.spy Credentials, 'index'
        sinon.stub(Credentials, 'enforceUnique').callsArgWith(1, null)

        Credentials.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Credentials.index.restore()
        Credentials.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Credentials

      it 'should store the serialized instance by key', ->
        multi.hset.should.have.been.calledWith 'credentials', instance.key, Credentials.serialize(instance)

      it 'should index the instance', ->
        Credentials.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Credentials, 'index'

        Credentials.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        Credentials.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Credentials.index.should.not.have.been.called




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        credential = credentials[0]
        json = jsonCredentials[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Credentials, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          key: credential.key
          secret: credential.secret
          role: 'app'

        Credentials.replace credential.key, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Credentials.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Credentials

      it 'should replace the existing instance', ->
        expect(instance.role).to.equal 'app'

      it 'should reindex the instance', ->
        Credentials.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(credential)


    describe 'with unknown credentials', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(2, null, null)
        Credentials.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Credentials.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'with invalid data', ->

      before (done) ->
        credential = credentials[0]

        Credentials.replace credential.key, { role: -1 }, (error, result) ->
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
        credential = credentials[0]
        json = jsonCredentials[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Credentials, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          role: 'app'

        Credentials.patch credential.key, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Credentials.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Credentials

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'credentials', instance.key, sinon.match('"role":"app"')

      it 'should reindex the instance', ->
        Credentials.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(credentials[0])


    describe 'with unknown credentials', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(2, null, null)
        Credentials.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Credentials.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null 


    describe 'with invalid data', ->

      before (done) ->
        credential = credentials[0]
        json = jsonCredentials[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Credentials.patch credential.key, { role: -1 }, (error, result) ->
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
        credential = credentials[0]
        sinon.spy Credentials, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Credentials, 'get').callsArgWith(2, null, credentials)
        Credentials.delete credential.key, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Credentials.deindex.restore()
        Credentials.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'credentials', credential.key

      it 'should deindex the instance', ->
        Credentials.deindex.should.have.been.calledWith sinon.match.object, sinon.match(credential)


    describe 'with unknown credentials', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(2, null, null)
        Credentials.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Credentials.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Credentials, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Credentials, 'get').callsArgWith(2, null, credentials)
        Credentials.delete keys, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Credentials.deindex.restore()
        Credentials.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'credentials', keys

      it 'should deindex each instance', ->
        credentials.forEach (doc) ->
          Credentials.deindex.should.have.been.calledWith sinon.match.object, doc

