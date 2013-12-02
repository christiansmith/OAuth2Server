# Test dependencies
cwd         = process.cwd()
path        = require 'path'
Faker       = require 'Faker'
chai        = require 'chai'
sinon       = require 'sinon'
sinonChai   = require 'sinon-chai'
request     = require 'supertest'
expect      = chai.expect




# Assertions
chai.use sinonChai
chai.should()




# Code under test
app         = require path.join(cwd, 'app')
Credentials = require path.join(cwd, 'models/Credentials')
Account     = require path.join(cwd, 'models/Account')
App         = require path.join(cwd, 'models/App')




describe 'resource owner password credentials grant', ->
  

  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {account,application} = {}


  before ->
    account            = new Account email: Faker.Internet.email()
    application        = new App

    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')


  describe 'POST /token', ->

    describe 'without app authentication', ->

      before (done) ->
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + invalidCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 401', ->
        res.statusCode.should.equal 401

      it 'should respond "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'




    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(App, 'getByKey').callsArgWith(1, null, application)
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, account)
        sinon.stub(Account.prototype, 'verifyPassword').callsArgWith(1, null, true)
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('grant_type=password&username=valid@example.com&password=secret&scope=https://domain.tld/resource')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.getByEmail.restore()
        Account.prototype.verifyPassword.restore()
        App.getByKey.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with access token', ->
        res.body.access_token.should.be.defined

      it 'should respond with token type', ->
        res.body.token_type.should.equal 'bearer'

      it 'should respond with expiration'
      it 'should respond with refresh token'




    describe 'with unknown username', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)      
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, null)
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('grant_type=password&username=unknown@example.com&password=secret&scope=https://resourceserver.tld')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.getByEmail.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_grant'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'invalid resource owner credentials'

      it 'should respond with an error uri'




    describe 'with missing username', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)      
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('grant_type=password&password=secret&scope=https://resourceserver.tld')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'missing username parameter'

      it 'should respond with an error uri'




    describe 'with mismatching password', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)      
        sinon.stub(Account, 'getByEmail').callsArgWith(2, null, account)
        sinon.stub(Account.prototype, 'verifyPassword').callsArgWith(1, null, false)
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('grant_type=password&username=valid@example.com&password=wrong&scope=https://resourceserver.tld')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.getByEmail.restore()
        Account.prototype.verifyPassword.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_grant'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'invalid resource owner credentials'

      it 'should respond with an error uri'




    describe 'with missing password', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)      
        sinon.stub(Account, 'getByEmail').callsArgWith(1, null, account)
        request(app)
          .post('/token')
          .set('Authorization', 'Basic ' + validCredentials)
          .send('grant_type=password&username=valid@example.com&scope=https://resourceserver.tld')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Account.getByEmail.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'missing password parameter'

      it 'should respond with an error uri'




    describe 'with brute force requests', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'




    describe 'with invalid scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'

    describe 'with missing scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'

    describe 'with excess scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'

