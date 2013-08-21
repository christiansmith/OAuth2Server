describe('refresh an access token', function () {

  describe('POST /token', function () {

    it('should require SSL');

    describe('with confidential/credentialed client', function () {
      it('should authenticate the client with HTTP basic authentication');
    });

    describe('with valid request', function () {
      it('should respond 200');
      it('should respond with an access token');
      it('should respond with a token type');
      it('should respond with an expiration');
      it('should respond with a refresh token');
      it('should respond with a scope');
      it('should respond with state');
    });

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

    describe('with invalid refresh token', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');      
    });

    describe('with missing refresh token', function () {
      it('should respond 400');
      it('should respond with an "invalid_request" error');
      it('should respond with an error description');
      it('should respond with an error uri');      
    });

  });

});