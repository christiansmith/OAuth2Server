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




# Errors
{UniqueValueError} = require 'modinha-redis'
{ValidationError}  = Account


describe 'Password Signup', ->




  {err,res,account} = {}
  {validSignup,invalidSignup} = {}
  {successInfo} = {}


  before ->
    account = new Account email: 'valid@example.com'

    validSignup   = email: 'valid@example.com', password: 'secret1337'
    invalidSignup = email: 'not-email', password: 'secret1337'

    successInfo         = message: 'Authenticated successfully!'
    unknownAccountInfo  = message: 'Unknown account.'
    invalidPasswordInfo = message: 'Invalid password.'




  describe 'POST /signup', ->

    describe 'with valid details', ->

      before (done) ->
        sinon.stub(Account, 'insert').callsArgWith(1, null, account)
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
        request
          .post('/signup')
          .send(validSignup)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.insert.restore()
        Account.authenticate.restore()

      it 'should respond 201', ->
        res.statusCode.should.equal 201

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the user', ->
        res.body.authenticated.should.equal true
        res.body.account.email.should.equal account.email

      it 'should not expose private user properties', ->
        expect(res.body.account.hash).to.be.undefined




    describe 'with a registered email', ->

      before (done) ->
        sinon.stub(Account, 'insert').callsArgWith(1, new UniqueValueError('email'))
        request
          .post('/signup')
          .send(validSignup)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.insert.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "UniqueValueError"', ->
        res.body.error.should.contain 'email must be unique'




    describe 'with invalid details', ->

      before (done) ->
        sinon.stub(Account, 'insert').callsArgWith(1, new ValidationError())
        request
          .post('/signup')
          .send(invalidSignup)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Account.insert.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with validation errors', ->
        res.body.error.should.equal 'Validation error.'




