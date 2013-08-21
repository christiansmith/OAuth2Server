describe('Client info', function () {

  describe('GET /clients', function () {

    describe('with unauthenticated user', function () {
      it('should respond 401');
      it('should respond with "Unauthorized"');      
    });

    describe('with unauthorized user', function () {
      it('should respond 403');
      it('should respond with "Unauthorized"');
    });

    describe('with authenticated user', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with the user\'s clients');      
    });

  });

  describe('GET /clients/:id', function () {

    describe('with unauthenticated user', function () {
      it('should respond 401');
      it('should respond with "Unauthorized"');
    });

    describe('with unauthorized user', function () {
      it('should respond 403');
      it('should respond with "Unauthorized"');
    });

    describe('with valid request', function () {
      it('should respond 200');
      it('should respond with JSON');
      it('should respond with the client');
    });

    describe('with unknown client', function () {
      it('should respond 404');
      it('should respond with "Not found"');
    });

  });

  describe('POST /clients', function () {});
  describe('PUT /clients/:id', function () {});
  describe('DELETE /clients/:id', function () {});

});