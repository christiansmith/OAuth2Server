cwd       = process.cwd()
path      = require 'path'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




Modinha = require 'modinha'
Account = require path.join(cwd, 'models/Account') 




redis     = require 'redis'
client    = redis.createClient()
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'Account', ->




  {err,account,info,validation} = {}

  validAccount =
    name:     'John Coltrane'
    email:    'trane@example.com'
    password: 'secret1337'




  beforeEach (done) ->
    sinon.spy multi, 'hset'
    sinon.spy multi, 'zadd'
    client.flushdb done

  afterEach ->
    multi.hset.restore()
    multi.zadd.restore()




  describe 'schema', ->

    beforeEach ->
      account = new Account
      validation = account.validate()

    it 'should have a unique id', ->
      Account.schema._id.type.should.equal 'string'

    it 'should generate a uuid for unique id', ->
      Account.schema._id.default.should.equal Modinha.defaults.uuid
    
    it 'should require unique id to be valid uuid', ->
      Account.schema._id.format.should.equal 'uuid'

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
      Account.schema.created.type.should.equal 'number'

    it 'should have "modified" timestamp', ->
      Account.schema.modified.type.should.equal 'number'




  describe 'creation', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        Account.create validAccount, (error, result) ->
          err = error
          account = result
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(account).to.be.instanceof Account

      it 'should set a created timestamp', ->
        account.created.should.be.a 'number'

      it 'should set a modified timestamp', ->
        account.modified.should.be.a 'number'

      it 'should hash the password', ->
        account.hash.should.be.a 'string'

      it 'should discard the password', ->
        expect(account.password).to.be.undefined

      it 'should store the instance as JSON', ->
        multi.hset.should.have.been.calledWith 'accounts', account._id, JSON.stringify(account)

      it 'should index the unique id', ->
        multi.zadd.should.have.been.calledWith 'accounts:_id', account.created, account._id

      it 'should index the email', ->
        multi.hset.should.have.been.calledWith 'accounts:email', account.email, account._id


    describe 'with invalid data', ->

      before (done) ->
        Account.create { password: 'secret1337' }, (error, result) ->
          err = error
          account = result
          done()

      it 'should provide a ValidationError', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(account).to.be.undefined


    describe 'with registered email', ->

      before (done) ->
        Account.create validAccount, ->
          Account.create validAccount, (error, instance) ->
            err = error
            account = instance;
            done()

      it 'should provide an error', ->
        err.name.should.equal 'RegisteredEmailError'

      it 'should not provide an instance', ->
        expect(account).to.be.undefined


    describe 'with a weak password', ->

      before (done) ->
        Account.create { email: 'valid@example.com', password: 'secret' }, (error, instance) ->
          err = error
          account = instance
          done()


      it 'should provide an error', ->
        err.name.should.equal 'InsecurePasswordError'

      it 'should not provide an instance', ->
        expect(account).to.be.undefined


    describe 'without a password', ->

      before (done) ->
        Account.create { email: 'valid@example.com' }, (error, instance) ->
          err = error
          account = instance
          done()

      it 'should provide an error', ->
        err.name.should.equal 'PasswordRequiredError'

      it 'should not provide an instance', ->
        expect(account).to.be.undefined




  describe 'retrieval', ->

    describe 'by id', ->

      before (done) ->
        Account.create validAccount, (e,result) ->
          Account.get result._id, (error, instance) ->
            err = error
            account = instance
            done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an account instance', ->
        expect(account).to.be.instanceof Account

      it 'should provide the account requested', ->
        account.email.should.equal validAccount.email


    describe 'by email', ->

      before (done) ->
        Account.create validAccount, ->
          Account.findByEmail validAccount.email, (error, instance) ->
            err = error
            account = instance
            done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an account instance', ->
        expect(account).to.be.instanceof Account

      it 'should provide the account requested', ->
        account.email.should.equal validAccount.email



  describe 'password verification', ->

    it 'should verify a correct password', (done) ->
      Account.create validAccount, (err, account) ->
        account.verifyPassword 'secret1337', (err, match) ->
          match.should.be.true
          done()

    it 'should not verify an incorrect password', (done) ->
      Account.create validAccount, (err, account) ->
        account.verifyPassword 'wrong', (err, match) ->
          match.should.be.false
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
        {email,password} = validAccount
        Account.create validAccount, ->
          Account.authenticate email, password, (error, instance, information) ->
            err = error
            account = instance
            info = information
            done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an Account instance', ->
        expect(account).to.be.instanceof Account

      it 'should provide a message', ->
        info.message.should.equal 'Authenticated successfully!'


    describe 'with unknown user', ->

      before (done) ->
        {email,password} = validAccount
        Account.authenticate email, password, (error, instance, information) ->
          err = error
          account = instance
          info = information
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide a false account', ->
        expect(account).to.be.false

      it 'should provide a message', ->
        info.message.should.equal 'Unknown account.'


    describe 'with incorrect password', ->

      before (done) ->
        {email} = validAccount
        Account.create validAccount, ->
          Account.authenticate email, 'wrong', (error, instance, information) ->
            err = error
            account = instance
            info = information
            done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide a false account', ->
        expect(account).to.be.false

      it 'should provide a message', ->
        info.message.should.equal 'Invalid password.'




  describe 'password reset', ->
  describe 'account verification', ->