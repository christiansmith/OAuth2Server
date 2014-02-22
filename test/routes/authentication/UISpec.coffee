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




# HTTP Client
request = supertest(app)




describe 'UI', ->


  {err,res} = {}


  describe 'GET /signin', ->

    before (done) ->
      request
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
      request
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
      request
        .get('/account')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 200', ->
      res.statusCode.should.equal 200

    it 'should respond with HTML', ->
      res.headers['content-type'].should.contain 'text/html'




  describe 'GET /account/apps', ->

    before (done) ->
      request
        .get('/account/apps')
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





