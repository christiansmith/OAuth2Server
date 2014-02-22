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
Group     = require path.join(cwd, 'models/Group')



# HTTP Client
request = supertest(app)




describe 'Groups REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {group,groups} = {}

  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    groups = []

    for i in [0..9]
      groups.push Group.initialize
        name: Faker.random.number(10).toString()




  describe 'GET /v1/groups', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/groups')
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
        sinon.stub(Group, 'list').callsArgWith(0, null, groups)
        request
          .get('/v1/groups')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with a list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal groups.length


    describe 'with paging', ->

      it 'should respond 200'
      it 'should respond with JSON'
      it 'should respond with a range'


    describe 'with empty results', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'list').callsArgWith(0, null, [])
        request
          .get('/v1/groups')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with invalid request', ->




  describe 'GET /v1/groups/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get("/v1/groups/id")
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
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, group)
        request
          .get('/v1/groups/id')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown resource', ->

      before (done) ->
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/groups/id')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'




  describe 'POST /v1/groups', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .post("/v1/groups")
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
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'insert').callsArgWith(1, null, group)
        request
          .post("/v1/groups")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(group)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.insert.restore()

      it 'should respond 201', ->
        res.statusCode.should.equal 201

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with invalid data', ->

      before (done) ->
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'insert').callsArgWith(1, new Group.ValidationError())
        request
          .post("/v1/groups")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(group)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.insert.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PUT /v1/groups/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .put("/v1/groups/id")
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
        sinon.stub(Group, 'replace').callsArgWith(2, null, group)
        request
          .put("/v1/groups/#{groups[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.replace.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'replace').callsArgWith(2, null, null)
        request
          .put("/v1/groups/#{groups[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.replace.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'replace').callsArgWith(2, new Group.ValidationError())
        request
          .put("/v1/groups/#{groups[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.replace.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'PATCH /v1/groups/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .patch("/v1/groups/id")
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
        group = groups[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'patch').callsArgWith(2, null, group)
        request
          .patch("/v1/groups/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.patch.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'name'


    describe 'with unknown app', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'patch').callsArgWith(2, null, null)
        request
          .patch("/v1/groups/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.patch.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with invalid data', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'patch').callsArgWith(2, new Group.ValidationError())
        request
          .patch("/v1/groups/#{groups[0]._id}")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.patch.restore()

      it 'should respond 400', ->
        res.statusCode.should.equal 400

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an error', ->
        res.body.should.have.property 'error'




  describe 'DELETE /v1/groups/:id', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .del("/v1/groups/id")
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
        sinon.stub(Group, 'delete').callsArgWith(1, null, null)
        request
          .del("/v1/groups/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .send({})
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.delete.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'


    describe 'with valid request', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Group, 'delete').callsArgWith(1, null, true)
        request
          .del("/v1/groups/id")
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Group.delete.restore()

      it 'should respond 204', ->
        res.statusCode.should.equal 204
        res.text.should.eql ''
        res.body.should.eql {}

