var cwd = process.cwd()
  , path = require('path')
  , chai = require('chai')
  , validate = require(path.join(cwd, 'lib/validate'))
  , Model = require(path.join(cwd, 'models/Model'))
  , Backend = require(path.join(cwd, 'models/Backend'))  
  , expect = chai.expect
  ;


describe('Model-extending constructor', function () {


  var Type, SubType, instance, validation, err;


  describe('...', function () {

    before(function () {
      Model.prototype.override = 'change me';
      Model.override = 'change me';
      Type = Model.extend({
        x: 1,
        override: 'changed'
      }, {
        x: 1,
        override: 'changed',
        schema: {}
      });
      instance = new Type();
    });

    it('should be extendable', function () {
      SubType = Type.extend();
      instance = new SubType();
      (instance instanceof SubType).should.equal(true);
      (instance instanceof Type).should.equal(true);
    });

    it('should set new prototype properties', function () {
      instance.x.should.equal(1);
    });
    
    it('should override prototype properties', function () {
      instance.override.should.equal('changed');
    });

    it('should set new static properties', function () {
      Type.x.should.equal(1);
    });

    it('should override static properties', function () {
      Type.override.should.equal('changed');
    });

    it('should have default static properties', function () {
      Type.timestamps.should.equal(true);
      Type.uniqueID.should.equal('_id');
    });

    it('should require a schema', function () {
      expect(function () { Model.extend() }).to.throw(Model.UndefinedSchemaError);
    });

    it('should initialize a default backend', function () {
      expect(Type.backend instanceof Backend).equals(true);
    });    

  });


  describe('prototype', function () {

    before(function () {
      Type = Model.extend(null, { schema: {} });
    });

    it('should reference the correct constructor', function () {
      Type.prototype.constructor.should.equal(Type);
    });

  });


  describe('superclass', function () {
    
    before(function () {
      Type = Model.extend(null, { schema: {} });
    });

    it('should reference the correct prototype', function () {
      Type.superclass.should.equal(Model.prototype);
    });

  });


  describe('instance', function () {

    before(function () {
      Type = Model.extend(null, { schema: {} });
      instance = new Type();
    });

    it('should be an instance of its constructor', function () {
      (instance instanceof Type).should.equal(true);
    });

    it('should be an instance of Model', function () {
      (instance instanceof Model).should.equal(true);
    });

  });


  describe('instance initialization', function () {

    before(function () {
      Type = Model.extend(null, {
        schema: {
          _id:  { type: 'string' },
          x: { type: 'string' },
          y: {
            properties: {
              z: { type: 'number' },
              d: { type: 'boolean', default: true }
            }
          },
          z: { type: 'boolean', default: true }
        }
      });
    });

    it('should initialize id if none is provided', function () {
      instance = new Type();
      (typeof instance._id).should.equal('string');

      instance = new Type({});
      (typeof instance._id).should.equal('string');
    });

    it('should not override a provided id', function () {
      var id = '9876rewq';
      instance = new Type({ _id: id });
      instance._id.should.equal(id);
    });

    it('should not initialize id if uniqueID is false', function () {
      NoID = Model.extend(null, {schema:{}})
      NoID.uniqueID = false;
      expect((new NoID)._id).equals(undefined);
    });

    it('should set attrs defined in schema', function () {
      instance = new Type({
        x:   'x',
        y:   {
          z: 1
        }
      });

      instance.x.should.equal('x');
      instance.y.z.should.equal(1);
    });

    it('should ignore attrs not defined in schema', function () {
      instance = new Type({ hacker: 'p0wn3d' });
      expect(instance.hacker).equals(undefined);
    });

    it('should set defaults defined in the schema', function () {
      instance = new Type();
      instance.z.should.equal(true);
      instance.y.d.should.equal(true);
    });

  });


  describe('instance validation', function () {

    before(function () {
      Type = Model.extend(null, {
        schema: {
          email: { type: 'string', format: 'email' }
        }
      });
    });

    describe('with valid data', function () {
      
      before(function () {
        instance = new Type({ email: 'valid@example.com' });
        validation = instance.validate();
      });

      it('should be valid', function () {
        validation.valid.should.equal(true);
      });
    });

    describe('with invalid data', function () {

      before(function () {
        instance = new Type({ email: 'not-valid' });
        validation = instance.validate();
      });

      it('should not be valid', function () {
        validation.valid.should.equal(false);
      });

      it('should return a ValidationError', function () {
        (validation instanceof validate.ValidationError).should.equal(true);
      });
    })

  });


  describe('instance creation', function () {

    before(function () {
      Type = Model.extend(null, {
        schema: {
          email: { type: 'string', format: 'email' },
          uniq:  { type: 'string', unique: true }
        }
      });
    });

    describe('with valid data', function () {

      before(function (done) {
        Type.backend.reset();
        Type.create({ email: 'valid@email.com' }, function (error, _instance) {
          err = error;
          instance = _instance;
          done();
        }); 
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      });

      it('should provide an instance', function () {
        (instance instanceof Type).should.equal(true);
      });

      it('should set the "created" timestamp', function () {
        instance.created.should.be.defined;
      });

      it('should set the "modified" timestamp', function () {
        instance.modified.should.be.defined;
      });

      it('should be saved to the backend', function () {
        Type.backend.documents[0].created.should.equal(instance.created);
      });

    });

    describe('with invalid data', function () {

      before(function (done) {
        Type.backend.reset();
        Type.create({ email: 'not-valid' }, function (error, _instance) {
          err = error;
          instance = _instance;
          done();
        }); 
      });

      it('should provide a validation error', function () {
        err.name.should.equal('ValidationError');
      });

      it('should not provide an instance', function () {
        expect(instance).equals(undefined);
      });
    });

    describe('with a duplicate values on unique attributes', function () {
      it('should provide a "duplicate value" error');
    });

  });


  describe('instance retrieval', function () {

    before(function () {
      Type = Model.extend(null, {
        schema: {
          email: { type: 'string', format: 'email' }
        }
      });
    });

    describe('by attribute', function () {

      before(function (done) {
        var data = { email: 'valid@example.com' };
        Type.create(data, function (e, type) {
          Type.find({ email: data.email }, function (error, _instance) {
            err = error;
            instance = _instance;
            done();
          });
        });        
      });

      it('should provide a null error', function () {
        expect(err).equals(null);
      })

      it('should provide an instance', function () {
        (instance instanceof Type).should.equal(true);
      });

    });

  });


});