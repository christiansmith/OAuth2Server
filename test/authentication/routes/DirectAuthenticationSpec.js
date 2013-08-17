
describe('direct authentication routes', function () {

  /**
   * QUESTIONS
   *
   * Configure to login with username vs. email?
   *
   * Admin user signup?
   *
   * Configure to lock anonymous account creation?
   */


  describe('POST /account', function () {

    describe('with valid details', function () {
      it('should respond 201');
      it('should respond with JSON');
      it('should respond with user info');
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


  describe('POST /login', function () {

    describe('with valid credentials', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with user info');
    });

    describe('without credentials', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "Missing credentials" error');
    });

    describe('with unknown user', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "Unknown user" error');
    });

    describe('with invalid password', function () {
      it('should respond 400');
      it('should respond with JSON');
      it('should respond with "Invalid password" error');
    });

  });


  describe('POST /logout', function () {
    it('should respond 204');
  });


  describe('GET /session', function () {

    describe('with authenticated user', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with user info');
      it('should respond with authenticated as true');
    });

    describe('with unauthenticated user', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should NOT respond with user info');
      it('should respond with authenticated as false');
    });

  });


  describe('password reset', function () {

  });


  describe('account verification', function () {

  });

});