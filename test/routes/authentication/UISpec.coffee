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
app     = require path.join(cwd, 'app')




describe 'UI', ->


  {err,res} = {}


  describe 'GET /signin', ->

    before (done) ->
      request(app)
        .get('/signin')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 200', ->
      res.statusCode.should.equal 200

    it 'should respond with HTML', ->
      res.headers['content-type'].should.contain 'text/html'




  describe 'GET /signup', ->

    before (done) ->
      request(app)
        .get('/signup')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 200', ->
      res.statusCode.should.equal 200

    it 'should respond with HTML', ->
      res.headers['content-type'].should.contain 'text/html'




  describe 'GET /account', ->

    before (done) ->
      request(app)
        .get('/account')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 200', ->
      res.statusCode.should.equal 200

    it 'should respond with HTML', ->
      res.headers['content-type'].should.contain 'text/html'




  describe 'GET /authorize', ->

    before (done) ->
      request(app)
        .get('/authorize')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 200', ->
      res.statusCode.should.equal 200

    it 'should respond with HTML', ->
      res.headers['content-type'].should.contain 'text/html'





