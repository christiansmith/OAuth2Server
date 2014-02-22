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
Account     = require path.join(cwd, 'models/Account')




# HTTP Client
request = supertest(app)




describe 'Password Login', ->



  {err,res,account} = {}
  {validLogin,missingCredentialsLogin,unknownAccountLogin,invalidPasswordLogin} = {}
  {successInfo,missingCredentialsInfo,unknownAccountInfo,invalidPasswordInfo} = {}



  before ->
    account = new Account email: 'valid@example.com'

    validLogin              = email: account.email, password: 'secret1337'
    missingCredentialsLogin = {}
    unknownAccountLogin     = email: 'unknown@example.com', password: 'doesntmatter'
    invalidPasswordLogin    = email: account.email, password: 'wrong'

    successInfo         = message: 'Authenticated successfully!'
    unknownAccountInfo  = message: 'Unknown account.'
    invalidPasswordInfo = message: 'Invalid password.'




  describe 'POST /login', ->

    describe 'with valid credentials', ->

      before (done) ->
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
        request
          .post('/login')
          .send(validLogin)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.authenticate.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an account', ->
        res.body.authenticated.should.equal true
        res.body.account.email.should.equal account.email




    describe 'without credentials', ->

      before (done) ->
        request
          .post('/login')
          .send({})
          .end (err, _res) ->
            res = _res
            done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Missing credentials" error', ->
        res.body.error.should.contain 'Missing credentials'




    describe 'with an unknown account', ->

      before (done) ->
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, false, unknownAccountInfo)
        request
          .post('/login')
          .send(unknownAccountLogin)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.authenticate.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Unknown account" error', ->
        res.body.error.should.contain 'Unknown account.'




    describe 'with an invalid password', ->

      before (done) ->
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, false, invalidPasswordInfo)
        request
          .post('/login')
          .send(invalidPasswordLogin)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.authenticate.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Invalid password" error', ->
        res.body.error.should.contain 'Invalid password'

