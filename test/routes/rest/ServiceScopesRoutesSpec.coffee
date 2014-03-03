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
Service     = require path.join(cwd, 'models/Service')
Scope       = require path.join(cwd, 'models/Scope')




# HTTP Client
request = supertest(app)




describe 'Service Scopes REST Routes', ->



  {err,res} = {}
  {credentials,validCredentials,invalidCredentials} = {}
  {service,services,scope,scopes} = {}

  before ->
    credentials        = new Credentials role: 'admin'
    validCredentials   = new Buffer(credentials.key + ':' + credentials.secret).toString('base64')
    invalidCredentials = new Buffer(credentials.key + ':wrong').toString('base64')

    # Mock data
    services = []
    scopes   = []

    for i in [0..9]
      services.push Service.initialize
        name:     "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
        email:    Faker.Internet.email()
        hash:     'private'
        password: 'secret1337'


    for i in [0..4]
      scopes.push Scope.initialize
        url: "https://#{Faker.Internet.domainName()}"
        description: Faker.Lorem.sentence()



  describe 'GET /v1/services/:serviceId/scopes', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/services/1234/scopes')
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
        service = services[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Service, 'get').callsArgWith(1, null, service)
        sinon.stub(Scope, 'list').callsArgWith(1, null, scopes)
        request
          .get('/v1/services/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Service.get.restore()
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
        service = services[1]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Service, 'get').callsArgWith(1, null, service)
        sinon.stub(Scope, 'list').callsArgWith(1, null, [])
        request
          .get('/v1/services/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Service.get.restore()
        Scope.list.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with an empty list', ->
        res.body.should.be.an 'array'
        res.body.length.should.equal 0


    describe 'with unknown service', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Service, 'get').callsArgWith(1, null, null)
        request
          .get('/v1/services/1234/scopes')
          .set('Authorization', 'Basic ' + validCredentials)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Service.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'



  describe 'POST /v1/services/:serviceId/scopes', ->

    describe 'without authentication', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, null)
        request
          .post("/v1/services/1234/scopes")
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
        service = services[0]
        scope = scopes[0]
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Service, 'get').callsArgWith(1, null, service)
        sinon.stub(Scope, 'insert').callsArgWith(1, null, scope)
        request
          .post("/v1/services/#{service._id}/scopes")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(scope)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Service.get.restore()
        Scope.insert.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with the resource', ->
        res.body.should.have.property 'url'

      it 'should set the service id of the scope', ->
        Scope.insert.should.have.been.calledWith sinon.match({
          serviceId: service._id
        })


    describe 'with unknown service', ->

      before (done) ->
        sinon.stub(Credentials, 'get').callsArgWith(1, null, credentials)
        sinon.stub(Service, 'get').callsArgWith(1, null, null)
        request
          .post("/v1/services/unknown/scopes")
          .set('Authorization', 'Basic ' + validCredentials)
          .send(scopes[0])
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        Credentials.get.restore()
        Service.get.restore()

      it 'should respond 404', ->
        res.statusCode.should.equal 404

      it 'should respond with JSON', ->
        res.headers['content-type'].should.contain 'application/json'

      it 'should respond with "Not found" error', ->
        res.body.error.should.equal 'Not found.'




