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
App     = require path.join(cwd, 'models/App')
Account = require path.join(cwd, 'models/Account')
Token   = require path.join(cwd, 'models/Token')
passport = require 'passport'




# HTTP Client
request = supertest(app)




describe 'implicit grant', ->




  {err,res} = {}
  {account,application,token} = {}




  describe 'GET /authorize', ->

    describe 'with text/html', ->

      before (done) ->
        request
          .get('/authorize')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with HTML', ->
        res.headers['content-type'].should.contain 'text/html'





    describe 'with valid request, unauthenticated user and existing access token', ->





    describe 'with valid request, existing session and existing access token', ->

      before (done) ->

        # DATA
        application = new App redirect_uri: "https://#{Faker.Internet.domainName()}/callback"
        account = new Account
        token = new Token appId: application._id, accountId: account._id, scope: Faker.Internet.domainName()
        successInfo = message: 'Authenticated successfully!'

        # STUBS
        sinon.stub(Token, 'existing').callsArgWith(2, null, token.project('issue'))
        sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
        sinon.stub(passport, 'deserializeUser').callsArgWith(1, null, account)

        # LOGIN
        agent = supertest.agent()
        login = email: 'valid@example.com', password: 'secret1337'
        request.post('/login').send(login).end (error, response) ->
          agent.saveCookies response

          # AUTH REQUEST
          req = supertest(app).get("/authorize?client_id=#{application._id}&response_type=token&redirect_uri=#{application.redirect_uri}")
          agent.attachCookies req
          req.end (error, response) ->
              err = error
              res = response
              done()



      after ->
        Token.existing.restore()
        Account.authenticate.restore()
        passport.deserializeUser.restore()

      it 'should respond 302', ->
        res.statusCode.should.equal 302

      it 'should redirect to the redirect uri', ->
        res.headers.location.should.contain application.redirect_uri

      it 'should respond with access token', ->
        res.headers.location.should.contain "access_token=#{token.access}"

      it 'should respond with token type', ->
        res.headers.location.should.contain "token_type=#{token.type}"

    #  it 'should respond with expriration'
    #  it 'should respond with scope'
    #  it 'should respond with state'


    describe 'with application/json', ->

      describe 'with valid request', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, application)
          request
            .get("/authorize?client_id=#{application._id}&response_type=token&redirect_uri=#{application.redirect_uri}")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 200', ->
          res.statusCode.should.equal 200

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should respond with app details', ->
          res.body.should.have.deep.property 'app.redirect_uri'

        it 'should respond with scope descriptions', ->
          res.body.should.have.property 'scope'








      describe 'with unsupported response type', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, application)
          request
            .get("/authorize?client_id=#{application._id}&response_type=invalid&redirect_uri=#{application.redirect_uri}")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 501', ->
          res.statusCode.should.equal 501

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should redirect to the redirect uri'

        it 'should respond with an error', ->
          res.body.error.should.equal 'unsupported_response_type'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Unsupported response type'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with missing response type', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, application)
          request
            .get("/authorize?client_id=#{application._id}&redirect_uri=#{application.redirect_uri}")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 501', ->
          res.statusCode.should.equal 501

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should redirect to the redirect uri'

        it 'should respond with an error', ->
          res.body.error.should.equal 'invalid_request'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Missing response type'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with invalid client id', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, null)
          request
            .get("/authorize?client_id=unknown&response_type=token&redirect_uri=#{application.redirect_uri}")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 403', ->
          res.statusCode.should.equal 403

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should NOT redirect'

        it 'should respond with an error', ->
          res.body.error.should.equal 'unauthorized_client'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Unknown client'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with missing client id', ->

        before (done) ->
          request
            .get("/authorize")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        it 'should respond 403', ->
          res.statusCode.should.equal 403

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should NOT redirect'

        it 'should respond with an error', ->
          res.body.error.should.equal 'unauthorized_client'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Missing client id'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with mismatching redirect uri', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, application)
          request
            .get("/authorize?client_id=#{application._id}&response_type=token&redirect_uri=https://wrong.tld")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 400', ->
          res.statusCode.should.equal 400

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should NOT redirect'

        it 'should respond with an error', ->
          res.body.error.should.equal 'invalid_request'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Mismatching redirect uri'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with missing redirect uri', ->

        before (done) ->
          application = new App redirect_uri: 'https://app.tld/callback'
          sinon.stub(App, 'get').callsArgWith(1, null, application)
          request
            .get("/authorize?client_id=#{application._id}&response_type=token")
            .set('Content-type', 'application/json')
            .end (error, response) ->
              err = error
              res = response
              done()

        after ->
          App.get.restore()

        it 'should respond 400', ->
          res.statusCode.should.equal 400

        it 'should respond with JSON', ->
          res.headers['content-type'].should.contain 'application/json'

        it 'should NOT redirect'

        it 'should respond with an error', ->
          res.body.error.should.equal 'invalid_request'

        it 'should respond with an error description', ->
          res.body.error_description.should.equal 'Missing redirect uri'

        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with invalid redirect uri', ->

        it 'should respond 400'
        it 'should respond with JSON'
        it 'should NOT redirect'
        it 'should respond with an error'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with missing state', ->

        it 'should respond 302'
        it 'should respond with JSON'
        it 'should redirect to the redirect uri'
        it 'should respond with an error'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with invalid scope', ->

        it 'should respond 400'
        it 'should respond with JSON'
        it 'should redirect to the redirect uri'
        it 'should respond with an error'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with missing scope', ->

        it 'should respond 400'
        it 'should respond with JSON'
        it 'should redirect to the redirect uri'
        it 'should respond with an error'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with excess scope', ->

        it 'should respond 400'
        it 'should respond with JSON'
        it 'should redirect to the redirect uri'
        it 'should respond with an error'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'without required group membership', ->

        it 'should respond 302'
        it 'should redirect to the redirect uri'
        it 'should respond with "access denied"'
        it 'should respond with an error description'
        it 'should respond with an error uri'
        it 'should respond with state'




      describe 'with required group membership', ->

        it 'should respond 302'
        it 'should redirect to the redirect uri'
        it 'should respond with access token'
        it 'should respond with token type'
        it 'should respond with expriration'
        it 'should respond with scope'
        it 'should respond with state'




  describe 'POST /authorize', ->


    {agent,accessGranted,accessDenied,successInfo} = {}
    {unsupportedResponseType,missingResponseType} = {}
    {invalidClientId,missingClientId} = {}
    {mismatchingRedirectUri,missingRedirectUri} = {}


    before (done) ->

      application = new App redirect_uri: "https://#{Faker.Internet.domainName()}/callback"
      account = new Account
      token = new Token appId: application._id, accountId: account._id, scope: Faker.Internet.domainName()
      sinon.stub(Token, 'insert').callsArgWith(1, null, token)

      accessGranted =
        authorized: true
        client_id: application._id
        response_type: 'token'
        redirect_uri: application.redirect_uri

      accessDenied =
        authorized: false
        client_id: application._id
        response_type: 'token'
        redirect_uri: application.redirect_uri

      unsupportedResponseType =
        authorized: true
        client_id: application._id
        response_type: 'invalid'
        redirect_uri: application.redirect_uri

      missingResponseType =
        authorized: true
        client_id: application._id
        redirect_uri: application.redirect_uri

      invalidClientId =
        authorized: true
        client_id: application._id
        response_type: 'token'
        redirect_uri: application.redirect_uri

      missingClientId =
        authorized: true
        response_type: 'token'
        redirect_uri: application.redirect_uri

      mismatchingRedirectUri =
        authorized: true
        client_id: application._id
        response_type: 'token'
        redirect_uri: application.redirect_uri + 'makeitfail'

      missingRedirectUri =
        authorized: true
        client_id: application._id
        response_type: 'token'

      successInfo = message: 'Authenticated successfully!'

      agent = supertest.agent()
      login = email: 'valid@example.com', password: 'secret1337'
      sinon.stub(Account, 'authenticate').callsArgWith(2, null, account, successInfo)
      sinon.stub(passport, 'deserializeUser').callsArgWith(1, null, account)
      supertest(app).post('/login').send(login).end (err, res) ->
        agent.saveCookies res
        done()

    after ->
      Token.insert.restore()
      Account.authenticate.restore()
      passport.deserializeUser.restore()




    describe 'without authentication', ->

      before (done) ->
        request
          .post('/authorize')
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 401', ->
        res.statusCode.should.equal 401

      it 'should respond "Unauthorized"', ->
        res.text.should.equal 'Unauthorized'




    describe 'with authorization granted', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(accessGranted)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 302', ->
        res.statusCode.should.equal 302

      it 'should redirect to the redirect uri', ->
        res.headers.location.should.contain application.redirect_uri

      it 'should respond with access token', ->
        res.headers.location.should.contain "access_token=#{token.access}"

      it 'should respond with token type', ->
        res.headers.location.should.contain "token_type=#{token.type}"

      it 'should respond with expriration'
      it 'should respond with scope'
      it 'should respond with state'




    describe 'with authorization denied', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(accessDenied)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 302', ->
        res.statusCode.should.equal 302

      it 'should redirect to the redirect uri', ->
        res.headers.location.should.contain application.redirect_uri

      it 'should respond with "access denied"', ->
        res.headers.location.should.contain 'error=access_denied'

      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with unsupported response type', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(unsupportedResponseType)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 501', ->
        res.statusCode.should.equal 501

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should redirect to the redirect uri'

      it 'should respond with an error', ->
        res.body.error.should.equal 'unsupported_response_type'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Unsupported response type'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with missing response type', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(missingResponseType)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 501', ->
        res.statusCode.should.equal 501

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should redirect to the redirect uri'

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Missing response type'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with invalid client id', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, null)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(invalidClientId)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 403', ->
        res.statusCode.should.equal 403

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should NOT redirect', ->
        res.statusCode.should.not.equal 302

      it 'should respond with an error', ->
        res.body.error.should.equal 'unauthorized_client'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Unknown client'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with missing client id', ->

      before (done) ->
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(missingClientId)
        req.end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 403', ->
        res.statusCode.should.equal 403

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should NOT redirect', ->
        res.statusCode.should.not.equal 302

      it 'should respond with an error', ->
        res.body.error.should.equal 'unauthorized_client'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Missing client id'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with mismatching redirect uri', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(mismatchingRedirectUri)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should NOT redirect', ->
        res.statusCode.should.not.equal 302

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Mismatching redirect uri'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with missing redirect uri', ->

      before (done) ->
        sinon.stub(App, 'get').callsArgWith(1, null, application)
        req = supertest(app).post('/authorize')
        agent.attachCookies req
        req.set('Content-type', 'application/json')
        req.send(missingRedirectUri)
        req.end (error, response) ->
            err = error
            res = response
            done()

      after ->
        App.get.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should NOT redirect', ->
        res.statusCode.should.not.equal 302

      it 'should respond with an error', ->
        res.body.error.should.equal 'invalid_request'

      it 'should respond with an error description', ->
        res.body.error_description.should.equal 'Missing redirect uri'

      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with invalid redirect uri', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should NOT redirect'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with missing state', ->

      it 'should respond 302'
      it 'should respond with JSON'
      it 'should redirect to the redirect uri'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with invalid scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should redirect to the redirect uri'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with missing scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should redirect to the redirect uri'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with excess scope', ->

      it 'should respond 400'
      it 'should respond with JSON'
      it 'should redirect to the redirect uri'
      it 'should respond with an error'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'without required group membership', ->

      it 'should respond 302'
      it 'should redirect to the redirect uri'
      it 'should respond with "access denied"'
      it 'should respond with an error description'
      it 'should respond with an error uri'
      it 'should respond with state'




    describe 'with required group membership', ->

      it 'should respond 302'
      it 'should redirect to the redirect uri'
      it 'should respond with access token'
      it 'should respond with token type'
      it 'should respond with expriration'
      it 'should respond with scope'
      it 'should respond with state'



