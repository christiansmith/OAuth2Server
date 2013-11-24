cwd     = process.cwd()
path    = require 'path'
chai    = require 'chai'
expect  = chai.expect
request = require 'supertest'
app     = require path.join(cwd, 'app')




describe 'Logout', ->


  {err,res} = {}


  describe 'POST /logout', ->

    before (done) ->  
      request(app)
        .post('/logout')
        .end (error, response) ->
          err = error
          res = response
          done()

    it 'should respond 204', ->
      res.statusCode.should.equal 204