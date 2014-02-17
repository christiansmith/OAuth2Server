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
Role   = require path.join(cwd, 'models/Role')
Account = require path.join(cwd, 'models/Account')
Scope = require path.join(cwd, 'models/Scope')




redis   = require('redis')
client  = redis.createClient()
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype
Role.__client   = client
Account.__client = client



describe 'Role', ->


  {data,roles,jsonRoles,err,instance,instances,role,account,scope,validation,update,deleted,keys} = {}


  before ->
    data = []
    for i in [0..9]
      data.push
        name: "role#{i}"

    roles = Role.initialize(data)
    jsonRoles = roles.map (s) -> Role.serialize(s)
    keys = roles.map (s) -> s.key




  describe 'schema', ->

    beforeEach ->
      instance = new Role
      validation = instance.validate()

    it 'should require name', ->
      validation.errors.name.attribute.should.equal 'required'

    it 'should have "created" timestamp', ->
      Role.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Role.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonRoles
        Role.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'roles:created', 0, 49

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Role

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonRoles
        Role.list { index: 'roles:modified' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'roles:modified'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Role


    describe 'with paging', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonRoles
        Role.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'roles:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Role


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Role.list { page: 2, size: 3 }, (error, results) ->
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
        role = roles[0]
        json = jsonRoles[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Role.get role[Role.uniqueId], (error, result) ->
          err = error
          instance = result

          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Role


    describe 'by string not found', ->

      before (done) ->
        Role.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonRoles
        Role.get keys, (error, results) ->
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
          expect(instance).to.be.instanceof Role


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        Role.get [], (error, results) ->
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
        sinon.spy Role, 'index'
        sinon.stub(Role, 'enforceUnique').callsArgWith(1, null)

        Role.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Role.index.restore()
        Role.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Role

      it 'should store the serialized instance by key', ->
        multi.hset.should.have.been.calledWith 'roles', instance[Role.uniqueId], Role.serialize(instance)

      it 'should index the instance', ->
        Role.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Role, 'index'

        Role.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore()
        Role.index.restore()

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Role.index.should.not.have.been.called




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        role = roles[0]
        json = jsonRoles[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Role, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          name: 'updated'

        Role.replace role[Role.uniqueId], update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Role.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Role

      it 'should replace the existing instance', ->
        expect(instance.name).to.equal 'updated'

      it 'should reindex the instance', ->
        Role.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(role)


    describe 'with unknown roles', ->

      before (done) ->
        sinon.stub(Role, 'get').callsArgWith(2, null, null)
        Role.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Role.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'with invalid data', ->

      before (done) ->
        role = roles[0]

        Role.replace role[Role.uniqueId], { role: -1 }, (error, result) ->
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
        role = roles[0]
        json = jsonRoles[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Role, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          name: 'patched'

        Role.patch role[Role.uniqueId], update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Role.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Role

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'roles', instance[Role.uniqueId], sinon.match('"name":"patched"')

      it 'should reindex the instance', ->
        Role.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(roles[0])


    describe 'with unknown role', ->

      before (done) ->
        sinon.stub(Role, 'get').callsArgWith(2, null, null)
        Role.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Role.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'with invalid data', ->

      before (done) ->
        role = roles[0]
        json = jsonRoles[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Role.patch role[Role.uniqueId], { name: -1 }, (error, result) ->
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
        role = roles[0]
        sinon.spy Role, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Role, 'get').callsArgWith(2, null, roles)
        Role.delete role.key, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Role.deindex.restore()
        Role.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'roles', role.key

      it 'should deindex the instance', ->
        Role.deindex.should.have.been.calledWith sinon.match.object, sinon.match(role)


    describe 'with unknown role', ->

      before (done) ->
        sinon.stub(Role, 'get').callsArgWith(2, null, null)
        Role.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Role.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Role, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Role, 'get').callsArgWith(2, null, roles)
        Role.delete keys, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Role.deindex.restore()
        Role.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'roles', keys

      it 'should deindex each instance', ->
        roles.forEach (doc) ->
          Role.deindex.should.have.been.calledWith sinon.match.object, doc




  describe 'add accounts', ->

    before (done) ->
      role = roles[0]
      account = new Account

      sinon.spy multi, 'zadd'
      Role.addAccounts role, account, done

    after ->
      multi.zadd.restore()

    it 'should index the role by the account', ->
      multi.zadd.should.have.been.calledWith "accounts:#{account._id}:roles", role.created, role._id

    it 'should index the account by the role', ->
      multi.zadd.should.have.been.calledWith "roles:#{role._id}:accounts", account.created, account._id



  describe 'remove accounts', ->

    before (done) ->
      role = roles[1]
      account = new Account

      sinon.spy multi, 'zrem'
      Role.removeAccounts role, account, done

    after ->
      multi.zrem.restore()

    it 'should deindex the role by the account', ->
      multi.zrem.should.have.been.calledWith "accounts:#{account._id}:roles", role._id

    it 'should deindex the account by the role', ->
      multi.zrem.should.have.been.calledWith "roles:#{role._id}:accounts", account._id



  describe 'list by account', ->

    before (done) ->
      account = new Account
      sinon.spy Role, 'list'
      Role.listByAccounts account, done

    after ->
      Role.list.restore()

    it 'should look in the accounts index', ->
      Role.list.should.have.been.calledWith { index: "accounts:#{account._id}:roles" }




  describe 'add scopes', ->

    before (done) ->
      role = roles[0]
      scope = new Scope url: 'https://resource.tld'

      sinon.spy multi, 'zadd'
      Role.addScopes role, scope, done

    after ->
      multi.zadd.restore()

    it 'should index the role by the scope', ->
      multi.zadd.should.have.been.calledWith "scopes:#{scope._id}:roles", role.created, role._id

    it 'should index the account by the role', ->
      multi.zadd.should.have.been.calledWith "roles:#{role._id}:scopes", scope.created, scope._id


  describe 'remove scopes', ->

    before (done) ->
      role = roles[1]
      scope = new Scope url: 'https://resource.tld'

      sinon.spy multi, 'zrem'
      Role.removeScopes role, scope, done

    after ->
      multi.zrem.restore()

    it 'should deindex the role by the scope', ->
      multi.zrem.should.have.been.calledWith "scopes:#{scope._id}:roles", role._id

    it 'should deindex the scope by the role', ->
      multi.zrem.should.have.been.calledWith "roles:#{role._id}:scopes", scope._id



  describe 'list by scope', ->

    before (done) ->
      scope = new Scope url: 'https://resource.tld'
      sinon.spy Role, 'list'
      Role.listByScopes scope, done

    after ->
      Role.list.restore()

    it 'should look in the scopes index', ->
      Role.list.should.have.been.calledWith sinon.match({ index: "scopes:#{scope._id}:roles" })



