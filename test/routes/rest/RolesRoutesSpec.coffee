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




# HTTP Client
request = supertest(app)




describe 'Roles REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {role,roles} = {}

  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    roles = []

    for i in [0..9]
      roles.push Role.initialize
        name: Faker.random.number(10).toString()




  describe 'GET /v1/roles', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/roles')
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'list').callsArgWith(0, null, roles)
        request
          .get('/v1/roles')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with a list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal roles.length


    describe 'with paging', ->

      it 'should respond 200'
      it 'should respond with JSON'
      it 'should respond with a range'


    describe 'with empty results', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'list').callsArgWith(0, null, [])
        request
          .get('/v1/roles')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with invalid request', ->




  describe 'GET /v1/roles/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get("/v1/roles/id")
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


    describe 'with valid request', ->

      before (done) ->
        role = roles[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, role)
        request
          .get('/v1/roles/id')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown resource', ->

      before (done) ->
        role = roles[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/roles/id')
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




  describe 'POST /v1/roles', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .post("/v1/roles")
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'insert').callsArgWith(1, null, role)
        request
          .post("/v1/roles")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(role)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.insert.restore()

      it 'should respond 201', ->
        res.statusCode.should.equal 201

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with invalid data', ->

      before (done) ->
        role = roles[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'insert').callsArgWith(1, new Role.ValidationError())
        request
          .post("/v1/roles")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(role)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.insert.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PUT /v1/roles/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/roles/id")
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'replace').callsArgWith(2, null, role)
        request
          .put("/v1/roles/#{roles[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.replace.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'replace').callsArgWith(2, null, null)
        request
          .put("/v1/roles/#{roles[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.replace.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'replace').callsArgWith(2, new Role.ValidationError())
        request
          .put("/v1/roles/#{roles[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.replace.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PATCH /v1/roles/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .patch("/v1/roles/id")
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
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'patch').callsArgWith(2, null, role)
        request
          .patch("/v1/roles/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.patch.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'patch').callsArgWith(2, null, null)
        request
          .patch("/v1/roles/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.patch.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'patch').callsArgWith(2, new Role.ValidationError())
        request
          .patch("/v1/roles/#{roles[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.patch.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'DELETE /v1/roles/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .del("/v1/roles/id")
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


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'delete').callsArgWith(1, null, null)
        request
          .del("/v1/roles/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.delete.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Role, 'delete').callsArgWith(1, null, true)
        request
          .del("/v1/roles/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Role.delete.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204
        res.text.should.eql ''
        res.body.should.eql {}

