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




Modinha = require 'modinha'
Group   = require path.join(cwd, 'models/Group')
Account = require path.join(cwd, 'models/Account')
App = require path.join(cwd, 'models/App')




redis   = require('redis')
client  = redis.createClient()
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype
Group.__client   = client
Account.__client = client



describe 'Group', ->


  {data,groups,jsonGroups,err,instance,instances,group,account,application,validation,update,deleted,keys} = {}


  before ->
    data = []
    for i in [0..9]
      data.push
        name: "group#{i}"

    groups = Group.initialize(data)
    jsonGroups = groups.map (s) -> Group.serialize(s)
    keys = groups.map (s) -> s.key




  describe 'schema', ->

    beforeEach ->
      instance = new Group
      validation = instance.validate()

    it 'should require name', ->
      validation.errors.name.attribute.should.equal 'required'

    it 'should have "created" timestamp', ->
      Group.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Group.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonGroups
        Group.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'groups:created', 0, 49

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Group

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonGroups
        Group.list { index: 'groups:modified' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'groups:modified'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Group


    describe 'with paging', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonGroups
        Group.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'groups:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Group


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Group.list { page: 2, size: 3 }, (error, results) ->
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
        group = groups[0]
        json = jsonGroups[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Group.get group[Group.uniqueId], (error, result) ->
          err = error
          instance = result

          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Group


    describe 'by string not found', ->

      before (done) ->
        Group.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonGroups
        Group.get keys, (error, results) ->
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
          expect(instance).to.be.instanceof Group


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        Group.get [], (error, results) ->
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
        sinon.spy Group, 'index'
        sinon.stub(Group, 'enforceUnique').callsArgWith(1, null)

        Group.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Group.index.restore()
        Group.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Group

      it 'should store the serialized instance by key', ->
        multi.hset.should.have.been.calledWith 'groups', instance[Group.uniqueId], Group.serialize(instance)

      it 'should index the instance', ->
        Group.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Group, 'index'

        Group.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore()
        Group.index.restore()

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Group.index.should.not.have.been.called




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        group = groups[0]
        json = jsonGroups[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Group, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          name: 'updated'

        Group.replace group[Group.uniqueId], update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Group.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Group

      it 'should replace the existing instance', ->
        expect(instance.name).to.equal 'updated'

      it 'should reindex the instance', ->
        Group.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(group)


    describe 'with unknown groups', ->

      before (done) ->
        sinon.stub(Group, 'get').callsArgWith(2, null, null)
        Group.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Group.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'with invalid data', ->

      before (done) ->
        group = groups[0]

        Group.replace group[Group.uniqueId], { role: -1 }, (error, result) ->
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
        group = groups[0]
        json = jsonGroups[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Group, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          name: 'patched'

        Group.patch group[Group.uniqueId], update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Group.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Group

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'groups', instance[Group.uniqueId], sinon.match('"name":"patched"')

      it 'should reindex the instance', ->
        Group.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(groups[0])


    describe 'with unknown group', ->

      before (done) ->
        sinon.stub(Group, 'get').callsArgWith(2, null, null)
        Group.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Group.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'with invalid data', ->

      before (done) ->
        group = groups[0]
        json = jsonGroups[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Group.patch group[Group.uniqueId], { name: -1 }, (error, result) ->
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
        group = groups[0]
        sinon.spy Group, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Group, 'get').callsArgWith(2, null, groups)
        Group.delete group.key, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Group.deindex.restore()
        Group.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'groups', group.key

      it 'should deindex the instance', ->
        Group.deindex.should.have.been.calledWith sinon.match.object, sinon.match(group)


    describe 'with unknown group', ->

      before (done) ->
        sinon.stub(Group, 'get').callsArgWith(2, null, null)
        Group.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Group.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Group, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Group, 'get').callsArgWith(2, null, groups)
        Group.delete keys, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Group.deindex.restore()
        Group.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'groups', keys

      it 'should deindex each instance', ->
        groups.forEach (doc) ->
          Group.deindex.should.have.been.calledWith sinon.match.object, doc




  describe 'add accounts', ->

    before (done) ->
      group = groups[0]
      account = new Account

      sinon.spy multi, 'zadd'
      Group.addAccounts group, account, done

    after ->
      multi.zadd.restore()

    it 'should index the group by the account', ->
      multi.zadd.should.have.been.calledWith "accounts:#{account._id}:groups", group.created, group._id

    it 'should index the account by the group', ->
      multi.zadd.should.have.been.calledWith "groups:#{group._id}:accounts", account.created, account._id



  describe 'remove accounts', ->

    before (done) ->
      group = groups[1]
      account = new Account

      sinon.spy multi, 'zrem'
      Group.removeAccounts group, account, done

    after ->
      multi.zrem.restore()

    it 'should deindex the group by the account', ->
      multi.zrem.should.have.been.calledWith "accounts:#{account._id}:groups", group._id

    it 'should deindex the account by the group', ->
      multi.zrem.should.have.been.calledWith "groups:#{group._id}:accounts", account._id



  describe 'list by account', ->

    before (done) ->
      account = new Account
      sinon.spy Group, 'list'
      Group.listByAccounts account, done

    after ->
      Group.list.restore()

    it 'should look in the accounts index', ->
      Group.list.should.have.been.calledWith { index: "accounts:#{account._id}:groups" }











  describe 'add apps', ->

    before (done) ->
      group = groups[0]
      application = new App

      sinon.spy multi, 'zadd'
      Group.addApps group, application, done

    after ->
      multi.zadd.restore()

    it 'should index the group by the app', ->
      multi.zadd.should.have.been.calledWith "apps:#{application._id}:groups", group.created, group._id

    it 'should index the app by the group', ->
      multi.zadd.should.have.been.calledWith "groups:#{group._id}:apps", application.created, application._id



  describe 'remove apps', ->

    before (done) ->
      group = groups[1]
      application = new App

      sinon.spy multi, 'zrem'
      Group.removeApps group, application, done

    after ->
      multi.zrem.restore()

    it 'should deindex the group by the app', ->
      multi.zrem.should.have.been.calledWith "apps:#{application._id}:groups", group._id

    it 'should deindex the app by the group', ->
      multi.zrem.should.have.been.calledWith "groups:#{group._id}:apps", application._id



  describe 'list by app', ->

    before (done) ->
      application = new App
      sinon.spy Group, 'list'
      Group.listByApps application, done

    after ->
      Group.list.restore()

    it 'should look in the apps index', ->
      Group.list.should.have.been.calledWith { index: "apps:#{application._id}:groups" }
