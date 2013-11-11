# Test dependencies
cwd       = process.cwd()
path      = require 'path'
chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect




chai.use sinonChai
chai.should()




Modinha = require 'modinha'
RedisDocument = require path.join(cwd, 'models/RedisDocument')




redis     = require 'redis'
client    = redis.createClient()
multi     = redis.Multi.prototype
rclient   = redis.RedisClient.prototype




describe 'RedisDocument', ->


  {Document,err,instance,instances} = {}


  validDocument =
    description: 'about'
    unique:      'indexed'
    secondary:   'value'
    reference:   '123'
    secret:      'fact'




  before ->
    schema =
      _id:         { type: 'string', required:  true, default: Modinha.defaults.uuid },
      description: { type: 'string', required:  true },
      unique:      { type: 'string', unique:    true },
      secret:      { type: 'string', private:   true },
      secondary:   { type: 'string', secondary: true } 
      reference:   { type: 'string', references: { collection: 'references'} }  

    Document = Modinha.define 'documents', schema  
    Document.extend RedisDocument

  beforeEach (done) ->
    sinon.spy multi, 'hset'
    sinon.spy multi, 'hdel'
    sinon.spy multi, 'zadd'
    done()

  afterEach ->
    multi.hset.restore()
    multi.hdel.restore()
    multi.zadd.restore()




  describe 'creation', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        Document.create validDocument, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a null value', ->
        expect(err).to.be.null

      it 'should provide an instance', ->
        expect(instance).to.be.instanceof Document

      it 'should set private properties', (done) ->
        sinon.spy Document, 'initialize'
        Document.create validDocument, ->
          Document.initialize.should.have.been.calledWith validDocument, { private: true }
          Document.initialize.restore()
          done()

      it 'should store the instance by unique identifier', ->
        multi.hset.should.have.been.calledWith 'documents', instance._id, Document.serialize(instance)

      it 'should index unique identifier', ->
        multi.zadd.should.have.been.calledWith 'documents:_id', instance.created, instance._id

      it 'should index unique schema properties', ->
        multi.hset.should.have.been.calledWith 'documents:unique', instance.unique, instance._id

      it 'should index secondary properties', ->
        multi.zadd.should.have.been.calledWith 'documents:secondary:value', instance.created, instance._id

      it 'should index referenced objects', ->
        multi.zadd.should.have.been.calledWith 'references:123:documents', instance.created, instance._id


    describe 'with duplicate unique values', ->

      it 'should check for existing documents'

      it 'should provide an error'
      
      it 'should not provide an instance'


    describe 'with invalid data', ->

      before (done) ->
        Document.create {}, (error, result) ->
          err = error
          instance = result
          done()

      it 'should provide a ValidationError', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined




  describe 'retrieval', ->

    describe 'get', ->

      describe 'with id string', ->

        before (done) ->
          doc = new Document validDocument
          json = JSON.stringify [doc]
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, json

          Document.get doc._id, (error, result) ->
            err = error
            instance = result
            rclient.hmget.restore()
            done()

        it 'should provide a null value', ->
          expect(err).to.be.null

        it 'should provide an instance', ->
          expect(instance).to.be.instanceof Document



      describe 'with id list', ->

        before (done) ->
          doc1 = new Document validDocument
          doc2 = new Document validDocument
          result = [JSON.stringify(doc1), JSON.stringify(doc2)]
          
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, result

          Document.get [doc1._id, doc2._id], (error, result) ->
            err = error
            instances = result
            rclient.hmget.restore()
            done()

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide an array of instances', ->
          Array.isArray(instances).should.be.true
          expect(instances[0]).to.be.instanceof Document



      describe 'with empty id list', ->

        before (done) ->
          Document.get [], (error, result) ->
            err = error
            instances = result
            done()

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide an empty array', ->
          Array.isArray(instances).should.be.true
          instances.length.should.equal 0



      describe 'without private option', ->

        before (done) ->
          doc = new Document validDocument
          json = JSON.stringify [doc]
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, json

          Document.get doc._id, (error, result) ->
            err = error
            instance = result
            rclient.hmget.restore()
            done()

        it 'should not initialize private properties', ->
          expect(instance.secret).to.be.undefined



      describe 'with private option', ->

        before (done) ->
          doc = new Document validDocument, private: true
          json = JSON.stringify doc
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, json

          Document.get doc._id, { private: true }, (error, result) ->
            err = error
            instance = result
            rclient.hmget.restore()           
            done()

        it 'should initialize private properties', ->
          instance.secret.should.equal validDocument.secret



      describe 'with selection', ->

        before (done) ->
          doc1    = new Document validDocument
          doc2    = new Document validDocument
          ids     = [ doc1._id, doc2._id ]
          result  = [JSON.stringify(doc1), JSON.stringify(doc2)]
          options = { select: ['description'] }
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, result

          Document.get ids, options, (error, result) ->
            err = error
            instances = result            
            done()         

        after ->
          rclient.hmget.restore()

        it 'should select the description', ->
          instances[0].description.should.be.defined
          expect(instances[0].secondary).to.be.undefined



      describe 'with unknown id', ->

        before (done) ->
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, [ null ]

          Document.get 'unknown', (error, result) ->
            err = error
            instance = result
            done()

        after ->
          rclient.hmget.restore()

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide a null result', ->
          expect(instance).to.be.null



    describe 'find', ->

      describe 'all', ->

        before (done) ->

          doc1    = new Document validDocument
          doc2    = new Document validDocument
          ids     = [ doc1._id, doc2._id ]
          result  = [JSON.stringify(doc1), JSON.stringify(doc2)]
          options = { select: ['description'] }

          sinon.stub(rclient, 'zrevrange')
            .callsArgWith 3, null, ids
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, result

          Document.find (error, result) ->
            err = error
            instances = result
            done()

        after ->
          rclient.zrevrange.restore()
          rclient.hmget.restore()

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide instances', ->
          instances.forEach (instance) ->
            expect(instance).to.be.instanceof Document


      describe 'with paging', ->

        before ->
          sinon.spy(rclient, 'zrevrange')
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, [ null ]

        after ->
          rclient.zrevrange.restore()
          rclient.hmget.restore()


        it 'should get a range of instances', (done) ->
          options = { page: 3, size: 2 }
          Document.find options, ->
            rclient.zrevrange.should.have.been
              .calledWith 'documents:_id', 4, 5
            done()


      describe 'by index', ->

        before ->
          sinon.spy(rclient, 'zrevrange')
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, [ null ]

        after ->
          rclient.zrevrange.restore()
          rclient.hmget.restore()

        it 'should get a range from a secondary index', (done) ->
          index = 'parent:id:documents'
          Document.find { index: index }, ->
            client.zrevrange.should.have.been
              .calledWith index, 0, 49
            done()


      describe 'by unique value index', ->

        before (done) ->
          document = new Document validDocument

          sinon.stub(rclient, 'hget')
            .callsArgWith 2, null, document._id
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, JSON.stringify(document)

          Document.findByUnique document._id, (error, result) ->
            err = error
            instance = result
            done()

        after ->
          rclient.hmget.restore()
          rclient.hget.restore()

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide an instance', ->
          expect(instance).to.be.instanceof Document



      describe 'by secondary index', ->

        before (done) ->
          doc1 = new Document validDocument
          doc2 = new Document validDocument
          docs = [JSON.stringify(doc1), JSON.stringify(doc2)]
          ids  = [doc2._id, doc1._id]

          sinon.stub(rclient, 'zrevrange')
            .callsArgWith 3, null, ids
          sinon.stub(rclient, 'hmget')
            .callsArgWith 2, null, docs

          Document.findBySecondary 'value', (error, results) ->
            err = error
            instances = results
            done()

        after ->
          rclient.zrevrange.restore()
          rclient.hmget.restore()        

        it 'should provide a null error', ->
          expect(err).to.be.null

        it 'should provide instances', ->
          instances.forEach (instance) ->
            expect(instance).to.be.instanceof Document


      describe 'by referenced object index', ->









  describe 'update', ->

    describe 'with valid data', ->

      beforeEach (done) ->
        sinon.stub(Document, 'get')
          .callsArgWith(1, null, Document.initialize(validDocument))

        Document.update { _id: 'uniqueId', description: 'updated' }, (error, result) ->
          err = error
          instance = result
          done()

      afterEach ->
        Document.get.restore()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should provide the updated instance', ->
        instance.description.should.equal 'updated'

      it 'should update the "modified" timestamp'

      it 'should store the updated instance', ->
        multi.hset.should.have.been.calledWith 'documents', instance._id, Document.serialize(instance)

      it 'should update indexes'


    describe 'with unknown instance', ->


    describe 'with invalid data', ->
    
      beforeEach (done) ->
        sinon.stub(Document, 'get')
          .callsArgWith(1, null, Document.initialize(validDocument))

        Document.update { description: null }, (error, result) ->
          err = error
          instance = result
          done()

      afterEach -> 
        Document.get.restore()

      it 'should provide a ValidationError', ->
        err.should.be.instanceof Modinha.ValidationError

      it 'should not provide an instance', ->
        expect(instance).to.be.undefined


    describe 'with private option', ->





  describe 'destruction', ->

    describe 'of a known instance', ->

      beforeEach (done) ->
        Document.destroy 'uniqueId', (error) ->
          err = error
          done()

      it 'should provide a null error', ->
        expect(err).to.be.null

      it 'should remove the stored instance', ->
        multi.hdel.should.have.been.calledWith 'documents', 'uniqueId'

      it 'should remove the instance identifier from indexes'

      it 'should remove keys from unique indexes'


