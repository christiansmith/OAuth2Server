cwd = process.cwd()
path = require 'path'
chai = require 'chai'
expect = chai.expect
request = require 'supertest'
app = require path.join(cwd, 'app')
User = require path.join(cwd, 'models/User') 


{err,res} = {}


describe 'Password Signup', ->

  describe 'POST /signup', ->

    describe 'with valid details', ->

      before (done) ->
        User.backend.reset()
        request(app)
          .post('/signup')
          .send({ email: 'smith@anvil.io', password: 'secret' })
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 201', ->
        res.statusCode.should.equal 201

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the user', ->
        res.body.authenticated.should.equal true
        res.body.user.email.should.equal 'smith@anvil.io'

      it 'should not expose private user properties', ->
        expect(res.body.user.hash).equals undefined


    describe 'with an existing username', ->

      before (done) ->
        signup = 
          username: 'anvilhacks'
          email: 'smith@anvil.io'
          password: 'secret'

        User.backend.reset()
        User.create signup, ->
          signup.email = 'other@anvil.io'
          request(app)
            .post('/signup')
            .send(signup)
            .end (error, response) ->
              err = error
              res = response
              done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "RegisteredUsernameError"', ->
        res.body.error.should.contain 'Username already registered'


    describe 'with a registered email', ->

      before (done) ->
        signup = 
          username: 'anvilhacks'
          email: 'smith@anvil.io'
          password: 'secret'

        User.backend.reset()
        User.create signup, ->
          signup.username = 'other'
          request(app)
            .post('/signup')
            .send(signup)
            .end (error, response) ->
              err = error
              res = response
              done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "RegisteredEmailError"', ->
        res.body.error.should.contain 'Email already registered'


    describe 'with invalid details', ->

      before (done) ->
        request(app)
          .post('/signup')
          .send({
            email: 'not-email'
            password: 'secret'
          })
          .end (error, response) ->
            err = error
            res = response
            done()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with validation errors', ->
        res.body.errors.email.attribute.should.equal 'format'
