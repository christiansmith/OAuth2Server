/**
 * AccessToken model
 *
 * The OAuth 2.0 Authorization Framework
 *
 * http://tools.ietf.org/html/rfc6749#section-1.4
 * http://tools.ietf.org/html/rfc6749#section-3.3
 * http://tools.ietf.org/html/rfc6749#section-6
 * http://tools.ietf.org/html/rfc6749#section-7.1
 * http://tools.ietf.org/html/rfc6749#section-10.3
 */

describe('AccessToken', function () {

  describe('schema', function () {
    it('should have a client id');
    it('should have an access token');
    it('should have a token type');
    it('should enumerate token types'); // bearer, mac
    it('should have an expiration');
    it('should have a refresh token');
    it('should have scope');
    it('may define a default scope');
    it('should have state??');
    it('should have "created" timestamp');
    it('should have "modified" timestamp');
  });

  describe('verification', function () {
    // AccessToken.verify(client_id, token, scope);
    it('should verify a valid token');
    it('should not verify a mismatching client');
    it('should not verify an unknown access token');
    it('should not verify an expired access token');

    describe('with default scope', function () {

    });

    describe('without default scope', function () {

    });

    // 
    it('should not verify an omitted scope');
    it('should not verify with insufficient scope ???');
  });

});