/**
 * Resource Owner Password Credentials Grant
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-4.3
 */

describe('resource owner password credentials grant', function () {


  describe('POST /authorize', function () {

    it('should require SSL');

    it('should require client authentication');

    it('should verify the user credentials');

    describe('with valid request', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with an access token');
      it('should respond with a token type');
      it('should respond with expiration');
      it('should respond with a refresh token');
    });

    describe('with unknown username', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with missing username', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with mismatching password', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with missing password', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with brute force requests', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('when scope is required', function () {

      describe('with invalid scope', function () {
        it('should respond 400');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');      
      });

      describe('with missing scope', function () {
        it('should respond 400');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');      
      });

      describe('with excess scope', function () {
        it('should ???')
      });

    });    

  });

});