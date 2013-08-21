/**
 * Client authentication
 * 
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-2.3.1
 * http://tools.ietf.org/html/rfc6749#section-10.1
 */

describe('Client authentication', function () {

  describe('with HTTP Basic authentication scheme', function () {
    it('should require SSL');
    it('should require a valid client id as username');
    it('should require a valid client secret as password');
  });

  describe('with request body (NOT RECOMMENDED)', function () {
    it('should require SSL');
    it('should require a client_id parameter');
    it('should require a client_secret parameter');
  });

  describe('with uri', function () {
    it('MUST NOT be supported');
  });

  it('must not include more than one authentication method in a request');

});