/**
 * Client model
 *
 * The OAuth 2.0 Authorization Framework
 * http://tools.ietf.org/html/rfc6749#section-2
 */

describe('Client', function () {

  describe('schema', function () {
    it('should have id');
    it('should require type');
    it('should enumerate types');   // confidential, public
    it('should have name');
    it('should have website');
    it('should have description');
    it('should have logo image');
    it('should have terms accepted');
    it('should have secret');
    it('should have redirect uris');
    it('should have "created" timestamp');
    it('should have "modified" timestamp');
  });


  describe('constructor', function () {
    it('should initialize id if none is provided');
    it('should set attrs defined in schema');
    it('should ignore attrs not defined in schema');
  });


  describe('registration', function () {
    it('should generate a secret');
  });


  describe('secret verification', function () {
    it('should verify a correct secret');
    it('should not verify an incorrect secret');
  });


  describe('authentication', function () {
    it('should authenticate a valid set of credentials');
    it('should not authenticate an invalid secret');
    it('should not authenticate an unknown client');
  });

});