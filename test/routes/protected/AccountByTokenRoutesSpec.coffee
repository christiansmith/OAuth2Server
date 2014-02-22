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
app     = require path.join(cwd, 'app')
Token   = require path.join(cwd, 'models/Token')
Account = require path.join(cwd, 'models/Account')




# HTTP Client
request = supertest(app)




# Errors
InvalidTokenError = require path.join(cwd, 'errors/InvalidTokenError')
InsufficientScopeError = require path.join(cwd, 'errors/InsufficientScopeError')




describe 'Account Routes', ->


  {err,res,token,account,update} = {}


  describe 'GET /v1/account', ->

    describe 'with missing access token', ->

      before (done) ->
        request
          .get('/v1/account')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Missing access token'


    describe 'with unknown access token', ->

      before (done) ->
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Unknown access token'))
        request
          .get('/v1/account')
          .set('Authorization', 'Bearer UNKNOWN')
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Unknown access token'


    describe 'with expired access token', ->

      before (done) ->
        token = new Token
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Expired access token'))
        request
          .get('/v1/account')
          .set('Authorization', "Bearer #{token.access}")
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Expired access token'


    describe 'with insufficient scope', ->

      before (done) ->
        token = new Token
        sinon.stub(Token, 'verify').callsArgWith(2, new InsufficientScopeError())
        request
          .get('/v1/account')
          .set('Authorization', "Bearer #{token.access}")
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'insufficient_scope'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Insufficient scope'



    describe 'with valid access token', ->

      before (done) ->
        token = new Token
        account = new Account email: 'valid@example.com'
        sinon.stub(Token, 'verify').callsArgWith(2, null, token)
        sinon.stub(Account, 'get').callsArgWith(1, null, account)
        request
          .get('/v1/account')
          .set('Authorization', "Bearer #{token.access}")
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()
        Account.get.restore()

      it 'should respond 200', ->

        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the account', ->
        res.body.email.should.equal account.email




  describe 'PATCH /v1/account', ->

    describe 'with missing access token', ->

    describe 'with missing access token', ->

      before (done) ->
        request
          .patch('/v1/account')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Missing access token'


    describe 'with unknown access token', ->

      before (done) ->
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Unknown access token'))
        request
          .patch('/v1/account')
          .set('Authorization', 'Bearer UNKNOWN')
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Unknown access token'


    describe 'with expired access token', ->

      before (done) ->
        token = new Token
        sinon.stub(Token, 'verify').callsArgWith(2, new InvalidTokenError('Expired access token'))
        request
          .patch('/v1/account')
          .set('Authorization', "Bearer #{token.access}")
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Expired access token'


    describe 'with insufficient scope', ->

      before (done) ->
        token = new Token
        sinon.stub(Token, 'verify').callsArgWith(2, new InsufficientScopeError())
        request
          .patch('/v1/account')
          .set('Authorization', "Bearer #{token.access}")
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'insufficient_scope'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Insufficient scope'


    describe 'with valid access token and valid request', ->

      before (done) ->
        account = new Account email: 'valid@example.com'
        token = new Token accountId: account._id
        updated = Account.initialize(account)
        update = email: 'updated@example.com'
        updated.email = update.email
        sinon.stub(Token, 'verify').callsArgWith(2, null, token)
        sinon.stub(Account, 'patch').callsArgWith(2, null, updated)
        request
          .patch('/v1/account')
          .send(update)
          .set('Authorization', "Bearer #{token.access}")
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()
        Account.patch.restore()

      it 'should respond 200', ->

        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the updated account', ->
        res.body.email.should.equal update.email

      it 'should patch the account', ->
        Account.patch.should.have.been.calledWith account._id, update


    describe 'with valid access token and invalid request', ->

      before (done) ->
        account = new Account email: 'valid@example.com'
        token = new Token accountId: account._id
        update = email: 'not-valid'

        sinon.stub(Token, 'verify').callsArgWith(2, null, token)
        sinon.stub(Account, 'patch').callsArgWith(2, new Account.ValidationError())
        request
          .patch('/v1/account')
          .send(update)
          .set('Authorization', "Bearer #{token.access}")
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Token.verify.restore()
        Account.patch.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.error.should.equal 'Validation error.'




