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
App         = require path.join(cwd, 'models/App')
Service     = require path.join(cwd, 'models/Service')
Token       = require path.join(cwd, 'models/Token')




# HTTP Client
request = supertest(app)




# Errors
InvalidTokenError = require path.join(cwd, 'errors/InvalidTokenError')
InsufficientScopeError = require path.join(cwd, 'errors/InsufficientScopeError')




describe 'Access Token Validation', ->


  {err,res} = {}
  {token,credentials,validCredentials,invalidCredentials} = {}


  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    token = new Token
      appId:     Faker.random.number(10).toString()
      accountId: Faker.random.number(10).toString()
      scope:     "https://#{Faker.Internet.domainName()}/resource"




  describe 'POST /access', ->

    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Token, 'verify').callsArgWith(2, null, token)
        request
          .post('/access')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('access_token=' + token.access + '&scope=' + token.scope)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Token.verify.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with confirmation', ->
        res.body.authorized.should.be.true

      it 'should respond with account id', ->
        res.body.account_id.should.equal token.accountId



    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        request
          .post('/access')
          .set('Authorization', 'Basic ' + invalidCredentials)
          .send('access_token=' + token.access + '&scope=' + token.scope)
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




    describe 'with multiple authentication methods', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should respond with an "invalid_request" error'
      it 'should respond with an error description'
      it 'should respond with an error uri'




    describe 'with unknown access token', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Unknown access token'))
        request
          .post('/access')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('access_token=' + token.access + '&scope=' + token.scope)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an "invalid_token" error', ->
        res.body.error.should.equal 'invalid_token'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Unknown access token'

      it 'should respond with an error uri'




    describe 'with expired access token', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Expired access token'))
        request
          .post('/access')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('access_token=' + token.access + '&scope=' + token.scope)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an "invalid_token" error', ->
        res.body.error.should.equal 'invalid_token'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Expired access token'

      it 'should respond with an error uri'




    describe 'with insufficient scope', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Token, 'verify').callsArgWith(2, new InsufficientScopeError())
        request
          .post('/access')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('access_token=' + token.access + '&scope=' + token.scope)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an "insufficient_scope" error', ->
        res.body.error.should.equal 'insufficient_scope'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Insufficient scope'

      it 'should respond with an error uri'




    describe 'without state', ->



