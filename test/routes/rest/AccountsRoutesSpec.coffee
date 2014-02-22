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
Account     = require path.join(cwd, 'models/Account')




# HTTP Client
request = supertest(app)




describe 'Accounts REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {account,accounts} = {}

  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    accounts = []

    for i in [0..9]
      accounts.push Account.initialize
        name:     "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
        email:    Faker.Internet.email()
        hash:     'private'
        password: 'secret1337'




  describe 'GET /v1/accounts', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/accounts')
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'list').callsArgWith(0, null, accounts)
        request
          .get('/v1/accounts')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'list').callsArgWith(0, null, [])
        request
          .get('/v1/accounts')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with invalid request', ->




  describe 'GET /v1/accounts/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get("/v1/accounts/id")
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


    describe 'with valid request', ->

      before (done) ->
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'get').callsArgWith(1, null, account)
        request
          .get('/v1/accounts/id')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'email'


    describe 'with unknown resource', ->

      before (done) ->
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/accounts/id')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'




  describe 'POST /v1/accounts', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .post("/v1/accounts")
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
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'insert').callsArgWith(1, null, account)
        request
          .post("/v1/accounts")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(account)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.insert.restore()

      it 'should respond 201', ->
        res.statusCode.should.equal 201

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'email'


    describe 'with invalid data', ->

      before (done) ->
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'insert').callsArgWith(1, new Account.PasswordRequiredError())
        request
          .post("/v1/accounts")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(account)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.insert.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PUT /v1/accounts/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/accounts/id")
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'replace').callsArgWith(2, null, account)
        request
          .put("/v1/accounts/#{accounts[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.replace.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'email'


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'replace').callsArgWith(2, null, null)
        request
          .put("/v1/accounts/#{accounts[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.replace.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'replace').callsArgWith(2, new Account.ValidationError())
        request
          .put("/v1/accounts/#{accounts[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.replace.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PATCH /v1/accounts/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .patch("/v1/accounts/id")
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
        account = accounts[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'patch').callsArgWith(2, null, account)
        request
          .patch("/v1/accounts/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.patch.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'email'


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'patch').callsArgWith(2, null, null)
        request
          .patch("/v1/accounts/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.patch.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'patch').callsArgWith(2, new Account.ValidationError())
        request
          .patch("/v1/accounts/#{accounts[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.patch.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'DELETE /v1/accounts/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .del("/v1/accounts/id")
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


    describe 'with unknown account', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'delete').callsArgWith(1, null, null)
        request
          .del("/v1/accounts/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.delete.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Account, 'delete').callsArgWith(1, null, true)
        request
          .del("/v1/accounts/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.delete.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204
        res.text.should.eql ''
        res.body.should.eql {}

