cwd = process.cwd()
path = require 'path'
chai = require 'chai'
expect = chai.expect
request = require 'supertest'
app = require path.join(cwd, 'app')
User = require path.join(cwd, 'models/User') 


{err,res,credentials} = {}


describe 'Session', ->

  describe 'GET /session', ->

    describe 'for authenticated user', ->

      agent = request.agent()

      before (done) ->
        credentials = { email: 'smith@anvil.io', password: 'secret' }
        User.backend.reset()
        User.create credentials, ->
          request(app)
            .post('/login')
            .send(credentials)
            .end (e,r) ->
              agent.saveCookies r
              req = request(app).get('/session')
              agent.attachCookies req
              req.end (error, response) ->
                err = error
                res = response
                done()
   
      it 'should respond 200', ->
        res.statusCode.should.equal 200
    
      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json' 

      it 'should respond with the user', ->
        res.body.authenticated.should.equal true
        res.body.user.email.should.equal credentials.email


    describe 'for unauthenticated user', ->

      before (done) ->
        request(app)
          .get('/session')
          .end (error, response) ->
            err = error
            res = response
            done()   

      it 'should respond 200', ->
        res.statusCode.should.eql 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.include 'application/json'

      it 'should respond with authenticated as false', -> 
        res.body.authenticated.should.equal false
