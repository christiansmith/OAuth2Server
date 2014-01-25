
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
app      = require path.join(cwd, 'app')
Account  = require path.join(cwd, 'models/Account')
App      = require path.join(cwd, 'models/App')
Token    = require path.join(cwd, 'models/Token')
passport = require 'passport'



describe 'Account apps', ->


  {err,res,account,validLogin,successInfo} = {}

  before ->
    account     = new Account email: 'valid@example.com'
    validLogin  = email: account.email, password: 'secret1337'
    successInfo = message: 'Authenticated successfully!'





  describe 'GET /session/apps', ->

    describe 'for authenticated user', ->

      agent = request.agent()

      before (done) ->
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
        sinon.stub(Account, 'listApps').callsArgWith(1, null, [new App])
        sinon.stub(passport, 'deserializeUser').callsArgWith(1, null, account)

        request(app)
          .post('/login')
          .send(validLogin)
          .end (e,r) ->
            agent.saveCookies r
            req = request(app).get('/session/apps')
            agent.attachCookies req
            req.end (error, response) ->
              err = error
              res = response
              done()

      after ->
        Account.authenticate.restore()
        Account.listApps.restore()
        passport.deserializeUser.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the user\'s apps', ->
        res.body[0]._id.should.be.a.string




    describe 'for unauthenticated user', ->

      before (done) ->
        request(app)
          .get('/session/apps')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 401', ->
        res.statusCode.should.eql 401

      it 'should respond with HTML', ->
        res.headers['content-type'].should.include 'text/html'

      it 'should respond with "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'




  describe 'DELETE /session/apps/:id', ->

    describe 'for authenticated user', ->

      agent = request.agent()

      before (done) ->
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
        sinon.stub(Token, 'revoke').callsArgWith(2, null, true)
        sinon.stub(passport, 'deserializeUser').callsArgWith(1, null, account)

        request(app)
          .post('/login')
          .send(validLogin)
          .end (e,r) ->
            agent.saveCookies r
            req = request(app).del('/session/apps/id')
            agent.attachCookies req
            req.end (error, response) ->
              err = error
              res = response
              done()

      after ->
        Account.authenticate.restore()
        Token.revoke.restore()
        passport.deserializeUser.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204

    #  it 'should respond with JSON', ->
    #    res.headers['content-type'].should.contain 'application/json'

    #  it 'should respond with the user\'s apps', ->
    #    res.body[0]._id.should.be.a.string


    describe 'for unauthenticated user', ->

      before (done) ->
        request(app)
          .del('/session/apps/id')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 401', ->
        res.statusCode.should.eql 401

      it 'should respond with HTML', ->
        res.headers['content-type'].should.include 'text/html'

      it 'should respond with "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'

