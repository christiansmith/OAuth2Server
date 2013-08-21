describe('delegated authentication (DRAFT)', function () {

  describe('POST /account', function () {

    it('should require SSL');

    describe('with valid details', function () {
      it('should respond 201');
      it('should respond with JSON');
      it('should respond with user info');
    });

    describe('with missing client credentials', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "unauthorized_client" error');
    });

    describe('with unknown client id', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "unauthorized_client" error');
    });

    describe('with invalid client secret', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "unauthorized_client" error');
    });

    describe('with registered email', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "registered email" error');      
    });

    describe('with registered username', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "registered username" error');
    });

    describe('with invalid details', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with validation errors');
    });

  });


  describe('POST /authorize', function () {
    // THIS IS THE SAME AS "resource owner password credentials grant" ????
  });
  

  describe('POST /signout', function () {
    it('should require SSL');
    it('should respond 204');
    it('should require client authentication');
    it('should revoke the access token');
  });


//  describe('GET /session', function () {
//
//    describe('with authenticated user', function () {
//      it('should respond 200');
//      it('should respond with JSON');
//      it('should respond with user info');
//      it('should respond with authenticated as true');
//    });
//
//    describe('with unauthenticated user', function () {
//      it('should respond 200');
//      it('should respond with JSON');
//      it('should NOT respond with user info');
//      it('should respond with authenticated as false');
//    });
//
//  });


  describe('password reset', function () {

  });


  describe('account verification', function () {

  });



});