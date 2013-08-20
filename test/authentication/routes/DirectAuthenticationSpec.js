
describe('direct authentication routes', function () {


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