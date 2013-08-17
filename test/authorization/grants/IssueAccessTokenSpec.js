/**
 * Issuing an Access Token
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-3.2
 * http://tools.ietf.org/html/rfc6749#section-4.1.3
 * http://tools.ietf.org/html/rfc6749#section-4.3.2
 * http://tools.ietf.org/html/rfc6749#section-4.4.2
 * http://tools.ietf.org/html/rfc6749#section-10.3
 * http://tools.ietf.org/html/rfc6749#section-10.4
 */

describe('token endpoint', function () {

  describe('POST /token', function () {

    it('should require SSL');

    describe('with confidential/credentialed client', function () {
      it('should authenticate the client with HTTP basic authentication');
    });

    /**
     * Token endpoint
     *
     * The OAuth 2.0 Authorization Framework
     * http://tools.ietf.org/html/rfc6749#section-5.1
     */

    describe('with valid request', function () {
      it('should respond 200');
      it('should respond with an access token');
      it('should respond with a token type');
      it('should respond with an expiration');
      it('should respond with a refresh token');
      it('should respond with a scope');
      it('should respond with state');
    });


    /**
     * Token endpoint
     *
     * The OAuth 2.0 Authorization Framework
     * http://tools.ietf.org/html/rfc6749#section-5.1
     */

    describe('with invalid grant type', function () {
      it('should respond 400');
      it('should respond with an "unsupported_grant_type" error');
      it('should respond with an error description');
      it('should respond with an error uri');      
    });

    describe('with missing grant type', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');      
    });

    describe('with authorization code issued to a different client', function () {
      it('should respond 400');
      it('should respond with an "invalid_grant" error');
      it('should respond with an error description');
      it('should respond with an error uri'); 
    });

    describe('with expired authorization code', function () {
      it('should respond 400');
      it('should respond with an "invalid_grant" error');
      it('should respond with an error description');
      it('should respond with an error uri');       
    });

    describe('with invalid authorization code', function () {
      it('should respond 400');
      it('should respond with an "invalid_grant" error');
      it('should respond with an error description');
      it('should respond with an error uri');       
    });

    describe('with missing authorization code', function () {
      it('should respond 400');
      it('should respond with an "invalid_grant" error');
      it('should respond with an error description');
      it('should respond with an error uri');       
    });

    describe('with invalid redirect uri', function () {
      it('should respond 400');
    });

    describe('with missing redirect uri', function () {
      it('should respond 400');
    });

    describe('with invalid client id', function () {
      it('should respond 400');
      it('should respond with an "invalid_client" error');
      it('should respond with an error description');
      it('should respond with an error uri'); 
    });

    describe('with missing client id', function () {
      it('should respond 400');
      it('should respond with an "invalid_client" error');
      it('should respond with an error description');
      it('should respond with an error uri'); 
    });

  });

});
