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
Role     = require path.join(cwd, 'models/Role')
Scope       = require path.join(cwd, 'models/Scope')




# HTTP Client
request = supertest(app)




describe 'Role Scopes REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {role,roles,scope,scopes} = {}

  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    roles = []
    scopes   = []

    for i in [0..9]
      roles.push Role.initialize
        name:     "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
        email:    Faker.Internet.email()
        hash:     'private'
        password: 'secret1337'


    for i in [0..4]
      scopes.push Scope.initialize
        name: Faker.random.number(10).toString()



  describe 'GET /v1/roles/:roleId/scopes', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/roles/1234/scopes')
          .set('Authorization', 'Basic ' + invalidCredentials)
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


    describe 'by default', ->

      before (done) ->
        role = roles[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, role)
        sinon.stub(Scope, 'list').callsArgWith(1, null, scopes)
        request
          .get('/v1/roles/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()
        Scope.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with a list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal scopes.length


    describe 'with paging', ->

      it 'should respond 200'
      it 'should respond with JSON'
      it 'should respond with a range'


    describe 'with empty results', ->

      before (done) ->
        role = roles[1]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, role)
        sinon.stub(Scope, 'list').callsArgWith(1, null, [])
        request
          .get('/v1/roles/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()
        Scope.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with unknown role', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/roles/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'



  describe 'PUT /v1/roles/:roleId/scopes/:scopeId', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/roles/1234/scopes/5678")
          .set('Authorization', 'Basic ' + invalidCredentials)
          .send({})
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


    describe 'with valid data', ->

      before (done) ->
        role = roles[0]
        scope = scopes[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, role)
        sinon.stub(Scope, 'get').callsArgWith(1, null, scope)
        request
          .put("/v1/roles/#{role._id}/scopes/#{scope._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()
        Scope.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'added'


    describe 'with unknown role', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/roles/#{roles[0]._id}/scopes/#{scopes[1]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with unknown scope', ->

      before (done) ->
        role = roles[3]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, role)
        sinon.stub(Scope, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/roles/#{role._id}/scopes/unknown")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Scope.get.restore()
        Role.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'




  describe 'DELETE /v1/roles/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .del('/v1/roles/1234/scopes/5678')
          .set('Authorization', 'Basic ' + invalidCredentials)
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


    describe 'with unknown role', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, null)
        request
          .del("/v1/roles/1234/scopes/5678")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, roles[1])
        sinon.stub(Role.prototype, 'removeScopes').callsArgWith(1, null, true)
        request
          .del("/v1/roles/1234/scopes/5678")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()
        Role.prototype.removeScopes.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204
        res.text.should.eql ''
        res.body.should.eql {}




