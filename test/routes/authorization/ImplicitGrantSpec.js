/**
 * Implicit Grant
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-4.2
 */

describe('implicit grant', function () {

  describe('GET /authorize', function () {

    it('should require SSL');


    describe('with valid request', function () {
      
      describe('and authenticated user', function () {
        it('should respond with an authorization prompt');
      });

      describe('and unauthenticated user', function () {
        it('should redirect to login');
      });

    });

    describe('with unsupported response type', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "unsupported_response_type" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with missing response type', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "invalid request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with invalid client id', function () {
      it('should NOT redirect');
      it('should respond with an "unauthorized_client" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with missing client id', function () {
      it('should NOT redirect');
      it('should respond with an "unauthorized_client" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with invalid redirect uri', function () {
      it('should NOT redirect');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');      
    });

    describe('with missing redirect uri', function () {
      it('should NOT redirect');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');      
    });

    describe('with mismatching redirect uri', function () {
      it('should NOT redirect');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with missing state', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "invalid request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('when scope is required', function () {

      describe('with invalid scope', function () {
        it('should redirect to the redirect uri');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');
        it('should respond with "state" provided by the client');        
      });

      describe('with missing scope', function () {
        it('should redirect to the redirect uri');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');
        it('should respond with "state" provided by the client');        
      });

      describe('with excess scope', function () {
        it('should ???')
      });

    });

  });


  describe('POST /authorize', function () {

    it('should require SSL');

    describe('when authorization granted', function () {
      it('should respond 302');
      it('should redirect to the redirect uri');
      it('should respond with an access token');
      it('should respond with a token type');
      it('should respond with an expiration');
      it('should respond with a scope');
      it('should respond with state');
    });

    describe('with "access denied" request', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "access denied" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');  
    });

    describe('with unauthenticated user', function () {
      it('should redirect to login');
    });

    describe('with unsupported response type', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "unsupported_response_type" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with missing response type', function () {
      it('should redirect to the redirect uri');
      it('should respond with an "invalid request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with invalid client id', function () {
      it('should NOT redirect');
      it('should respond with an "unauthorized_client" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');
    });

    describe('with missing client id', function () {
      it('should NOT redirect');
      it('should respond with an "unauthorized_client" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');      
    });

    describe('with invalid redirect uri', function () {
      it('should NOT redirect');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');      
    });

    describe('with missing redirect uri', function () {
      it('should NOT redirect');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
      it('should respond with "state" provided by the client');      
    });

    describe('when scope is required', function () {

      describe('with invalid scope', function () {
        it('should redirect to the redirect uri');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');
        it('should respond with "state" provided by the client');        
      });

      describe('with missing scope', function () {
        it('should redirect to the redirect uri');
        it('should respond with an "invalid_scope" error');
        it('should respond with an error description');
        it('should respond with an error uri');
        it('should respond with "state" provided by the client');        
      });

      describe('with excess scope', function () {
        it('should ???')
      });

    });

  });


});