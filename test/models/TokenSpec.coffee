# Test dependencies
cwd       = process.cwd()
path      = require 'path'
Faker     = require 'Faker'
chai      = require 'chai'
async     = require 'async'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect



chai.use sinonChai
chai.should()




Modinha   = require 'modinha'
Token     = require path.join(cwd, 'models/Token')  




redis     = Token.__redis
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'Token', ->


  {data,tokens,jsonTokens,err,instance,instances,token,validation,update,deleted,ids} = {}


  before ->
    data = []
    for i in [0..9]
      data.push
        appId: Faker.random.number(100).toString()
        accountId: Faker.random.number(100).toString()
        scope: Faker.Internet.domainName()

    tokens = Token.initialize(data)
    jsonTokens = tokens.map (s) -> Token.serialize(s)
    ids = tokens.map (s) -> s.url




  describe 'schema', ->

    beforeEach ->
      token = new Token { url: 'wrong' }
      validation = token.validate()

    it 'should require access token', ->
      Token.schema.access.required.should.be.true

    it 'should generate a random string for access token', ->
      token.access.should.be.a.string

    it 'should use access token as unique id', ->
      Token.uniqueId.should.equal 'access'
    
    it 'should have a token type', ->
      Token.schema.type.type.should.equal 'string'

    it 'should enumerate token types', ->
      Token.schema.type.enum.should.contain 'bearer'
      Token.schema.type.enum.should.contain 'mac'

    it 'should have a default token type of "bearer"', ->
      token.type.should.equal 'bearer'

    it 'should require an app id', ->
      validation.errors.appId.attribute.should.equal 'required'

    it 'should require an account id', ->
      validation.errors.accountId.attribute.should.equal 'required'

    it 'should have an expiration'
    it 'should have a refresh token'
    
    it 'should have scope', ->
      Token.schema.scope.type.should.equal 'string'

    it 'may define a default scope'
    it 'should have state?'

    it 'should have "created" timestamp', ->
      Token.schema.created.default.should.equal Modinha.defaults.timestamp

    it 'should have "modified" timestamp', ->
      Token.schema.modified.default.should.equal Modinha.defaults.timestamp




  describe 'list', ->

    describe 'by default', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonTokens
        Token.list (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the created index', ->
        rclient.zrevrange.should.have.been.calledWith 'tokens:created', 0, 49  

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Token

      it 'should provide the list in reverse chronological order', ->
        rclient.zrevrange.should.have.been.called


    describe 'by index', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonTokens
        Token.list { index: 'tokens:modified' }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should query the provided index', ->
        rclient.zrevrange.should.have.been.calledWith 'tokens:modified'

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Token


    describe 'with paging', ->

      before (done) ->
        sinon.spy rclient, 'zrevrange'
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonTokens
        Token.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()
        rclient.zrevrange.restore()

      it 'should retrieve a range of values', ->
        rclient.zrevrange.should.have.been.calledWith 'tokens:created', 3, 5

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Token


    describe 'with no results', ->

      before (done) ->
        sinon.stub(rclient, 'zrevrange').callsArgWith(3, null, [])
        Token.list { page: 2, size: 3 }, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.zrevrange.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an empty list', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0




  describe 'get', ->

    describe 'by string', ->

      before (done) ->
        token = tokens[0]
        json = jsonTokens[0]
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, [json]
        Token.get token.access, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Token

      it 'should not initialize private properties', ->
        expect(instance.secret).to.be.undefined


    describe 'by string not found', ->

      before (done) ->
        Token.get 'unknown', (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a null result', ->
        expect(instance).to.be.null


    describe 'by array', ->

      before (done) ->
        sinon.stub(rclient, 'hmget').callsArgWith 2, null, jsonTokens
        Token.get ids, (error, results) ->
          err = error
          instances = results
          done()

      after ->
        rclient.hmget.restore()

      it 'should provide null error', ->
        expect(err).to.be.null

      it 'should provide a list of instances', ->
        instances.length.should.equal 10  
        instances.forEach (instance) ->
          expect(instance).to.be.instanceof Token


#    describe 'by array not found', ->
#
#      it 'should provide a null error'
#      it 'should provide a list of instances'
#      it 'should not provide null values in the list'


    describe 'with empty array', ->

      before (done) ->
        Token.get [], (error, results) ->
          err = error
          instances = results
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide an empty array', ->
        Array.isArray(instances).should.be.true
        instances.length.should.equal 0     




  describe 'insert', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Token, 'index'
        sinon.stub(Token, 'enforceUnique').callsArgWith(1, null)

        Token.insert data[0], (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        multi.hset.restore()
        multi.zadd.restore()
        Token.index.restore()
        Token.enforceUnique.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the inserted instance', ->
        expect(instance).to.be.instanceof Token

      it 'should not provide private properties', ->
        expect(instance.secret).to.be.undefined

      it 'should store the serialized instance by access token', ->
        multi.hset.should.have.been.calledWith 'tokens', instance.access, Token.serialize(instance)

      it 'should index the instance', ->
        Token.index.should.have.been.calledWith sinon.match.object, sinon.match(instance)


    describe 'with invalid data', ->

      before (done) ->
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'
        sinon.spy Token, 'index'

        Token.insert {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        multi.hset.restore()
        multi.zadd.restore() 
        Token.index.restore()   

      it 'should provide a validation error', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined

      it 'should not store the data', ->
        multi.hset.should.not.have.been.called

      it 'should not index the data', ->
        Token.index.should.not.have.been.called




  describe 'replace', ->

    describe 'with valid data', ->

      before (done) ->
        token = tokens[0]
        json = jsonTokens[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Token, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          access: token.access
          appId: Faker.random.number(100).toString()
          accountId: Faker.random.number(100).toString()
          scope: Faker.Internet.domainName()

        Token.replace token.access, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Token.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the replaced instance', ->
        expect(instance).to.be.instanceof Token

      it 'should replace the existing instance', ->
        expect(instance.scope).not.to.equal token.scope
        instance.scope.should.be.a.string

      it 'should reindex the instance', ->
        Token.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(token)


    describe 'with unknown token', ->

      before (done) ->
        sinon.stub(Token, 'get').callsArgWith(2, null, null)
        Token.replace 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null  


    describe 'with invalid data', ->

      before (done) ->
        token = tokens[0]

        sinon.stub(Token, 'get').callsArgWith(2, null, token)
        Token.replace token.url, { description: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'patch', ->

    describe 'with valid data', ->

      before (done) ->
        token = tokens[0]
        json = jsonTokens[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy Token, 'reindex'
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        update =
          scope: 'https://updated.tld'


        Token.patch token.access, update, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        Token.reindex.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the patched instance', ->
        expect(instance).to.be.instanceof Token

      it 'should overwrite the stored data', ->
        multi.hset.should.have.been.calledWith 'tokens', instance.access, sinon.match('"scope":"https://updated.tld"')

      it 'should reindex the instance', ->
        Token.reindex.should.have.been.calledWith sinon.match.object, sinon.match(update), sinon.match(tokens[0])


    describe 'with unknown token', ->

      before (done) ->
        sinon.stub(Token, 'get').callsArgWith(2, null, null)
        Token.patch 'unknown', {}, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide an null error', ->
        expect(err).to.be.null

      it 'should not provide an instance', ->
        expect(instance).to.be.null 


    describe 'with invalid data', ->

      before (done) ->
        token = tokens[0]
        json = jsonTokens[0]

        sinon.stub(rclient, 'hmget').callsArgWith(2, null, [json])
        sinon.spy multi, 'hset'
        sinon.spy multi, 'zadd'

        Token.patch token.access, { scope: -1 }, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        rclient.hmget.restore()
        multi.hset.restore()
        multi.zadd.restore()

      it 'should provide a validation error', ->
        expect(err).to.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'delete', ->

    describe 'by string', ->

      before (done) ->
        token = tokens[0]
        sinon.spy Token, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Token, 'get').callsArgWith(2, null, token)
        Token.delete token.access, (error, result) ->
          err = error
          deleted = result
          done()

      after ->
        Token.deindex.restore()
        Token.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'tokens', token.access

      it 'should deindex the instance', ->
        Token.deindex.should.have.been.calledWith sinon.match.object, sinon.match(token)


    describe 'by array', ->

      beforeEach (done) ->
        sinon.spy Token, 'deindex'
        sinon.spy multi, 'hdel'
        sinon.stub(Token, 'get').callsArgWith(2, null, tokens)
        Token.delete ids, (error, result) ->
          err = error
          deleted = result
          done()

      afterEach ->
        Token.deindex.restore()
        Token.get.restore()
        multi.hdel.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide confirmation', ->
        deleted.should.be.true

      it 'should remove each stored instance', ->
        multi.hdel.should.have.been.calledWith 'tokens', ids

      it 'should deindex each instance', ->
        tokens.forEach (doc) ->
          Token.deindex.should.have.been.calledWith sinon.match.object, doc




  describe 'issue', ->

    beforeEach (done) ->
      token =  tokens[0]
      app =     { _id: token.appId }
      account = { _id: token.accountId }
      options = { scope: token.scope }

      sinon.stub(Token, 'insert').callsArgWith 1, null, token
      Token.issue app, account, options, (error, instance) ->
        err = error
        token = instance
        done()

    afterEach ->
      Token.insert.restore()

    it 'should provide a null error', ->
      expect(err).to.be.null

    it 'should provide a projection', ->
      expect(token).not.to.be.instanceof Token

    it 'should not initialize app id', ->
      expect(token.appId).to.be.undefined

    it 'should not initialize account id', ->
      expect(token.accountId).to.be.undefined

    it 'should store the token', ->
      Token.insert.should.have.been.calledWith data[0]

    it 'should generate an access token', ->
      token.access_token.should.be.a.string

    it 'should set an expiration'

    it 'should generate a refresh token'

    it 'should set scope', ->
      token.scope.should.equal tokens[0].scope

    it 'should invalidate/destroy previously issued access tokens for this user/app?'




  describe 'verification', ->

    describe 'with valid details', ->

      before (done) ->
        token = tokens[0]
        sinon.stub(Token, 'get').callsArgWith(1, null, token)
        Token.verify token.access, token.scope, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the token', ->
        expect(token).to.be.instanceof Token


    describe 'with unknown access token', ->

      before (done) ->
        token = tokens[0]
        sinon.stub(Token, 'get').callsArgWith(1, null, null)
        Token.verify token.access, token.scope, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide an "InvalidTokenError"', ->
        err.name.should.equal 'InvalidTokenError'

      it 'should not provide verification', ->
        expect(instance).to.be.undefined


    describe 'with expired access token', ->

      it 'should provide an "InvalidTokenError"'
      it 'should not provide verification'


    describe 'with insufficient scope', ->

      before (done) ->
        token = tokens[0]
        sinon.stub(Token, 'get').callsArgWith(1, null, token)
        Token.verify token.access, 'insufficient', (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide an "InsufficientScopeError"', ->
        err.name.should.equal 'InsufficientScopeError'

      it 'should not provide verification', ->
        expect(instance).to.be.undefined


    describe 'with omitted scope', ->

      before (done) ->
        token = tokens[0]
        sinon.stub(Token, 'get').callsArgWith(1, null, token)
        Token.verify token.access, undefined, (error, result) ->
          err = error
          instance = result
          done()

      after ->
        Token.get.restore()

      it 'should provide an "InsufficientScopeError"', ->
        err.name.should.equal 'InsufficientScopeError'

      it 'should not provide verification', ->
        expect(instance).to.be.undefined


    describe 'with omitted scope and defined default', ->


