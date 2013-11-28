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
Modinha = require 'modinha'
Account = require path.join(cwd, 'models/Account')




# Redis lib for spying and stubbing
redis   = Account.__redis
client  = Account.__client
multi   = redis.Multi.prototype
rclient = redis.RedisClient.prototype




describe 'Account', ->


  {data,account,accounts,jsonAccounts} = {}
  {err,validation,instance,instances,update,deleted,original,ids,info} = {}
  

  before ->
  
    # Mock data
    data = []

    for i in [0..9]
      data.push
        name:     "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
        email:    Faker.Internet.email()
        hash:     'private'
        password: 'secret1337'

    accounts = Account.initialize(data, { private: true })
    jsonAccounts = accounts.map (d) -> 
      Account.serialize(d)
    ids = accounts.map (d) ->
      d._id




  describe 'schema', ->

    beforeEach ->
      account = new Account
      validation = account.validate()

    it 'should have unique identifier', ->
      Account.schema[Account.uniqueId].should.be.an.object

    it 'should have display name', ->
      Account.schema.name.type.should.equal 'string'

    it 'should require email', ->
      validation.errors.email.attribute.should.equal 'required'

    it 'should require email to be valid', ->
      validation = (new Account email: 'not-valid').validate()
      validation.errors.email.attribute.should.equal 'format'

    it 'should have roles', ->
      Account.schema.roles.type.should.equal 'array'

    it 'should have no roles by default', ->
      account.roles.length.should.equal 0

    it 'should have hash', ->
      Account.schema.hash.type.should.equal 'string'

    it 'should protect hash', ->
      Account.schema.hash.private.should.equal true

    it 'should have "created" timestamp', ->
      Account.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Account.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'accounts:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Account

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.hash).to.be.undefined

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


#    describe 'by index', ->
#
#      before (done) ->
#        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
#        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
#        Account.list { index: 'accounts:secondary:value' }, (error, results) ->
#          err = error
#          instances = results
#          done()
#
#      after ->
#        rclient.hmget.restore()
#        rclient.zrevrange.restore()
#
#      it 'should query the provided index', ->
#        rclient.zrevrange.should.have.been.calledWith 'accounts:secondary:value'
#
#      it 'should provide null error', ->
#        expect(err).to.be.null
#
#      it 'should provide a list of instances', ->
#        instances.length.should.equal 10
#        instances.forEach (instance) ->
#          expect(instance).to.be.instanceof Account
#
#      it 'should not initialize private properties', ->
#        instances.forEach (instance) ->
#          expect(instance.secret).to.be.undefined
#
#
    describe 'with paging', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids.slice(3,5)
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'accounts:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Account


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Account.list { page: 2, size: 3 }, (error, results) ->
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


    describe 'with selection', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.list { select: [ 'name', 'hash' ] }, (error, results) ->
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
          expect(instance).to.be.instanceof Account

      it 'should only initialize selected properties', ->
        instances.forEach (instance) ->
          expect(instance._id).to.be.undefined
          instance.name.should.be.a.string

      it 'should initialize private properties if selected', ->
        instances.forEach (instance) ->
          instance.hash.should.be.a.string


    describe 'with private option', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.list { private: true }, (error, results) ->
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
          expect(instance).to.be.instanceof Account

      it 'should intialize private properties', ->
        instances.forEach (instance) ->
          instance.hash.should.equal 'private'


    describe 'in chronological order', ->

      before (done) ->
        sinon.stub(rclient, 'zrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.list { order: 'normal' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrange.restore()

      it 'should query the created index', ->
        rclient.zrange.should.have.been.calledWith 'accounts:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10  
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Account

      it 'should not initialize private properties', ->
        instances.forEach (instance) ->
          expect(instance.hash).to.be.undefined

      it 'should provide the list in chronological order', ->
        rclient.zrange.should.have.been.called




  describe 'get', ->

    describe 'by string', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Account.get accounts[0]._id, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Account

      it 'should not initialize private properties', ->
        expect(instance.hash).to.be.undefined


    describe 'by string not found', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, null
        Account.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.get ids, (error, results) ->
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
          expect(instance).to.be.instanceof Account

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
        Account.get [], (error, results) ->
          err = error
          instances = results
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an empty array', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0     


    describe 'with selection', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith 3, null, ids
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonAccounts
        Account.get ids, { select: [ 'name', 'hash' ] }, (error, results) ->
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
          expect(instance).to.be.instanceof Account

      it 'should only initialize selected properties', ->
        instances.forEach (instance) ->
          expect(instance._id).to.be.undefined
          instance.name.should.be.a.string

      it 'should initialize private properties if selected', ->
        instances.forEach (instance) ->
          instance.hash.should.be.a.string


    describe 'with private option', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Account.get account._id, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Account

      it 'should initialize private properties', ->
        expect(instance.hash).to.equal 'private'




  describe 'insert', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Account, 'index'
        sinon.stub(Account, 'enforceUnique').callsArgWith(1, null)
        sinon.stub(multi, 'exec').callsArgWith 0, null

        Account.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Account.index.restore()
        Account.enforceUnique.restore()
        multi.exec.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Account

      it 'should not provide private properties', ->
        expect(instance.hash).to.be.undefined

      it 'should store the hashed password', ->
        multi.hset.should.have.been.calledWith 'accounts', instance._id, sinon.match('"hash":"')

      it 'should discard the password', ->
        expect(instance.password).to.be.undefined
        multi.hset.should.not.have.been.calledWith 'accounts', instance._id, sinon.match('password')

      it 'should store the serialized instance by unique id', ->
        multi.hset.should.have.been.calledWith 'accounts', instance._id, sinon.match('"name":"' + instance.name + '"')

      it 'should index the instance', ->
        Account.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Account, 'index'

        Account.insert { email: 'not-valid', password: 'secret1337' }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        Account.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Account.index.should.not.have.been.called


    describe 'with a weak password', ->

      before (done) ->
        Account.insert { email: 'valid@example.com', password: 'secret' }, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide an error', ->
        err.name.should.equal 'InsecurePasswordError'

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'without a password', ->

      before (done) ->
        Account.insert { email: 'valid@example.com' }, (error, instance) ->
          err = error
          account = instance
          done()

      it 'should provide an error', ->
        err.name.should.equal 'PasswordRequiredError'

      it 'should not provide an instance', ->
        expect(account).to.be.undefined


    describe 'with private values option', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Account, 'index'
        sinon.stub(Account, 'enforceUnique').callsArgWith(1, null)

        Account.insert data[0], { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Account.index.restore()
        Account.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Account

      it 'should provide private properties', ->
        expect(instance.hash).to.be.a.string


    describe 'with duplicate email', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Account, 'index'
        sinon.stub(Account, 'getByEmail')
          .callsArgWith 1, null, accounts[0]

        Account.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Account.index.restore()
        Account.getByEmail.restore()

      it 'should provide a unique value error', ->
        expect(err).to.be.instanceof Account.UniqueValueError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Account, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: account._id
          name: 'George Jetson'
          email: Faker.Internet.email()

        Account.replace account._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Account.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Account

      it 'should not provide private properties', ->
        expect(instance.hash).to.be.undefined

      it 'should replace the existing instance', ->
        expect(instance.name).to.equal 'George Jetson'

      it 'should reindex the instance', ->
        Account.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), accounts[0]


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Account, 'get').callsArgWith(2, null, null)
        Account.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Account.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'with invalid data', ->

      before (done) ->
        account = accounts[0]

        Account.replace account._id, { email: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'with private values option', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Account, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: account._id
          name: 'George Jetson'
          email: Faker.Internet.email()
          hash: 'rehashed'

        Account.replace account._id, update, { private: true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Account.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Account

      it 'should provide private properties', ->
        expect(instance.hash).to.equal 'rehashed'


    describe 'with duplicate unique values', ->

      beforeEach (done) ->
        account1 = accounts[0]
        account2 = Account.initialize(accounts[1])
        account2.email = account1.email
        sinon.spy Account, 'index'
        sinon.stub(Account, 'get')
          .callsArgWith 2, null, account2
        sinon.stub(Account, 'getByEmail')
          .callsArgWith 1, null, account1       

        Account.replace account2._id, account2, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        Account.get.restore()
        Account.index.restore()
        Account.getByEmail.restore()

      it 'should provide a unique value error', ->
        expect(err).to.be.instanceof Account.UniqueValueError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'patch', ->

    describe 'with valid data', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Account, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: account._id
          name: 'George Jetson'


        Account.patch account._id, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Account.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Account

      it 'should not provide private properties', ->
        expect(instance.hash).to.be.undefined

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'accounts', instance._id, sinon.match('"name":"George Jetson"')

      it 'should reindex the instance', ->
        Account.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(accounts[0])


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Account, 'get').callsArgWith(2, null, null)
        Account.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Account.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null 


    describe 'with invalid data', ->

      before (done) ->
        account = accounts[0]
        json = jsonAccounts[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Account.patch account._id, { email: -1 }, (error, result) ->
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
        account = accounts[0]
        json = jsonAccounts[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Account, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          _id: account._id
          email: Faker.Internet.email()


        Account.patch account._id, update, { private:true }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Account.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Account

      it 'should provide private properties', ->
        instance.hash.should.equal account.hash


    describe 'with duplicate unique values', ->

      beforeEach (done) ->
        account = accounts[0]
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Account, 'index'
        sinon.stub(Account, 'getByEmail')
          .callsArgWith 1, new Account.UniqueValueError()        

        Account.patch account._id, account, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Account.index.restore()
        Account.getByEmail.restore()

      it 'should provide a unique value error', ->
        expect(err).to.be.instanceof Account.UniqueValueError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'delete', ->

    describe 'by string', ->

      before (done) ->
        instance = accounts[0]
        sinon.spy Account, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Account, 'get').callsArgWith(2, null, instance)
        Account.delete instance._id, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Account.deindex.restore()
        Account.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'accounts', instance._id

      it 'should deindex the instance', ->
        Account.deindex.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Account, 'get').callsArgWith(2, null, null)
        Account.delete 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Account.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Account, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Account, 'get').callsArgWith(2, null, accounts)
        Account.delete ids, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Account.deindex.restore()
        Account.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'accounts', ids

      it 'should deindex each instance', ->
        accounts.forEach (account) ->
          Account.deindex.should.have.been.calledWith sinon.match.object, account




  describe 'password verification', ->

    it 'should verify a correct password', (done) ->
      sinon.stub(multi, 'exec').callsArg(0)
      Account.insert data[0], { private:true }, (err, account) ->
        account.verifyPassword 'secret1337', (err, match) ->
          match.should.be.true
          multi.exec.restore()
          done()

    it 'should not verify an incorrect password', (done) ->
      sinon.stub(multi, 'exec').callsArg(0)
      Account.insert data[0], { private: true }, (err, account) ->
        account.verifyPassword 'wrong', (err, match) ->
          match.should.be.false
          multi.exec.restore()
          done()

    it 'should not verify against an undefined hash', (done) ->
      account = new Account
      expect(account.hash).to.be.undefined
      account.verifyPassword 'secret', (err, match) ->
        match.should.be.false
        done()




  describe 'authentication', ->

    describe 'with valid email and password credentials', ->

      before (done) ->
        {email,password} = data[0]
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, accounts[0])
        sinon.stub(Account.prototype, 'verifyPassword').callsArgWith(1, null, true)
        Account.authenticate email, password, (error, instance, information) ->
          err = error
          account = instance
          info = information
          done()

      after ->
        Account.getByEmail.restore()
        Account.prototype.verifyPassword.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an Account instance', ->
        expect(account).to.be.instanceof Account

      it 'should provide a message', ->
        info.message.should.equal 'Authenticated successfully!'


    describe 'with unknown user', ->

      before (done) ->
        {email,password} = data[0]
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, null)
        Account.authenticate email, password, (error, instance, information) ->
          err = error
          account = instance
          info = information
          done()

      after ->
        Account.getByEmail.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide a false account', ->
        expect(account).to.be.false

      it 'should provide a message', ->
        info.message.should.equal 'Unknown account.'


    describe 'with incorrect password', ->

      before (done) ->
        {email} = data[0]
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, accounts[0])
        sinon.stub(Account.prototype, 'verifyPassword').callsArgWith(1, null, false)        

        Account.authenticate email, 'wrong', (error, instance, information) ->
          err = error
          account = instance
          info = information
          done()

      after ->
        Account.getByEmail.restore()
        Account.prototype.verifyPassword.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide a false account', ->
        expect(account).to.be.false

      it 'should provide a message', ->
        info.message.should.equal 'Invalid password.'




  describe 'password reset', ->




  describe 'account verification', ->




