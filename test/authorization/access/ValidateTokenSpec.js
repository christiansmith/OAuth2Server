/**
 * Access token validation
 *
 * The OAuth 2.0 Authorization Framework
 * ...
 * http://tools.ietf.org/html/rfc6749#section-1.4
 * http://tools.ietf.org/html/rfc6749#section-7
 * http://tools.ietf.org/html/rfc6749#section-10.3
 */

describe('access token validation', function () {

  describe('GET /token/verify', function () {

    it('should require SSL');

    describe('with valid request', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with ???');
    });

    describe('with unauthenticated client', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with more than one authentication method', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with client mismatch', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_token" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with unknown access token', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_token" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with expired access token', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "invalid_token" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('with insufficient scope', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with an "insufficient_scope" error');
      it('should respond with an error description');
      it('should respond with an error uri');
    });

    describe('without state', function () {});

  });

});