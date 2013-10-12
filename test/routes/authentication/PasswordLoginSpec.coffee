cwd = process.cwd()
path = require 'path'
chai = require 'chai'
expect = chai.expect
request = require 'supertest'
app = require path.join(cwd, 'app')
User = require path.join(cwd, 'models/User') 


{err,res,credentials} = {}


describe 'Password Login', ->

  describe 'POST /login', ->

    describe 'with valid credentials', ->
      
      before (done) ->
        credentials = { email: 'smith@anvil.io', password: 'secret' }
        User.backend.reset()
        User.create credentials, ->
          request(app)
            .post('/login')
            .send(credentials)
            .end (error, response) ->
              err = error
              res = response
              done()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'      

      it 'should respond with a user', ->
        res.body.authenticated.should.equal true
        res.body.user.email.should.equal credentials.email


    describe 'without credentials', ->

      before (done) ->
        request(app)
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


    describe 'with an unknown user', ->

      before (done) ->
        request(app)
          .post('/login')
          .send({ email: 'unknown@example.com', password: 'secret' })
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Unknown user" error', ->
        res.body.error.should.contain 'Unknown user'


    describe 'with an invalid password', ->

      before (done) ->
        User.backend.reset()
        User.create { email: 'smith@anvil.io', password: 'secret' }, ->
          request(app)
            .post('/login')
            .send({ email: 'smith@anvil.io', password: 'wrong' })
            .end (error, response) ->
              err = error
              res = response
              done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Invalid password" error', ->
        res.body.error.should.contain 'Invalid password'

