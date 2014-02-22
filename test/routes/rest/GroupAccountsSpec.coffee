# Test dependencies
cwd         = process.cwd()
path        = require 'path'
Faker       = require 'Faker'
chai        = require 'chai'
sinon       = require 'sinon'
sinonChai   = require 'sinon-chai'
supertest   = require 'supertest'
expect      = chai.expect




# Assertions
chai.use sinonChai
chai.should()




# Code under test
app         = require path.join(cwd, 'app')
Credentials = require path.join(cwd, 'models/Credentials')
Group       = require path.join(cwd, 'models/Group')
Account     = require path.join(cwd, 'models/Account')




# HTTP Client
request = supertest(app)




describe 'Group Accounts REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {group,groups,account,accounts} = {}



  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    groups   = []
    accounts = []

    for i in [0..4]
      groups.push Group.initialize
        name: Faker.random.number(10).toString()


    for i in [0..9]
      accounts.push Account.initialize
        name:     "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
        email:    Faker.Internet.email()
        hash:     'private'
        password: 'secret1337'



  describe 'GET /v1/groups/:groupId/accounts', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/groups/1234/accounts')
          .set('Authorization', 'Basic ' + invalidCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()

      it 'should respond 401', ->
        res.statusCode.should.equal 401

      it 'should respond "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'


    describe 'by default', ->

      before (done) ->
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, group)
        sinon.stub(Account, 'list').callsArgWith(1, null, accounts)
        request
          .get('/v1/groups/1234/accounts')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()
        Account.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with a list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal accounts.length


    describe 'with paging', ->

      it 'should respond 200'
      it 'should respond with JSON'
      it 'should respond with a range'


    describe 'with empty results', ->

      before (done) ->
        group = groups[1]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, group)
        sinon.stub(Account, 'list').callsArgWith(1, null, [])
        request
          .get('/v1/groups/1234/accounts')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()
        Account.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with unknown group', ->

      before (done) ->
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/groups/1234/accounts')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()


      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'



  describe 'PUT /v1/groups/:groupId/accounts/:accountId', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/groups/1234/accounts/5678")
          .set('Authorization', 'Basic ' + invalidCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()

      it 'should respond 401', ->
        res.statusCode.should.equal 401

      it 'should respond "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'


    describe 'with valid data', ->

      before (done) ->
        group = groups[0]
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, group)
        sinon.stub(Account, 'get').callsArgWith(1, null, account)
        request
          .put("/v1/groups/#{group._id}/accounts/#{account._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()
        Account.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'added'


    describe 'with unknown group', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/groups/#{groups[0]._id}/accounts/#{accounts[1]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with unknown account', ->

      before (done) ->
        group = groups[3]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, group)
        sinon.stub(Account, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/groups/#{group._id}/accounts/unknown")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.get.restore()
        Group.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'




  describe 'DELETE /v1/groups/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .del('/v1/groups/1234/accounts/5678')
          .set('Authorization', 'Basic ' + invalidCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()

      it 'should respond 401', ->
        res.statusCode.should.equal 401

      it 'should respond "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'


    describe 'with unknown group', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, null)
        request
          .del("/v1/groups/1234/accounts/5678")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, groups[1])
        sinon.stub(Group.prototype, 'removeAccounts').callsArgWith(1, null, true)
        request
          .del("/v1/groups/1234/accounts/5678")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()
        Group.prototype.removeAccounts.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204
        res.text.should.eql ''
        res.body.should.eql {}




