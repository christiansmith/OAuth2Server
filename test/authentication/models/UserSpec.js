describe('User', function () {

  describe('schema', function () {

    it('should have id')

    describe('info', function () {
      it('should have id');
      it('should have first name');
      it('should have last name');
      it('should have username');
      it('should have email');
      it('should require email to be valid');
      it('should have "created" timestamp');
      it('should have "modified" timestamp');
    });

    it('should have salt');
    it('should have hash');

    describe('tokens', function () {
      it('should have "local" access_token');
      it('should have "facebook" access_token');
    });

    describe('credentials', function () {
      describe('local', function () {
        it('should have access_token');
        it('should have secret')
      });

      describe('facebook', function () {
        it('should have access_token');
        it('should have secret')
      });
    });

  });


  describe('constructor', function () {
    it('should initialize id if none is provided');
    it('should set attrs defined in schema');
    it('should ignore attrs not defined in schema');
  });


  describe('creation', function () {
    it('should require a password');
    it('should hash the password');
  });


  describe('retrieval', function () {

    describe('by default', function () {
      it('should not expose hash');
      it('should not expose credentials');
    });

    describe('with "raw" option', function () {
      it('should include tokens');
      it('should include hash');
      it('should include credentials');
    });

    describe('with "tokens" option', function () {
      it('should include tokens');
    }); 

    describe('with "credentials" option', function () {
      it('should include credentials');
    });

  });


  describe('password verification', function () {
    it('should verify a correct password');
    it('should not verify an incorrect password');
  });


  describe('authentication', function () {
    it('should authenticate a valid set of credentials');
    it('should not authenticate an invalid password');
    it('should not authenticate an unknown user');
  });


  describe('password reset', function () {});


  describe('account verification', function () {});

});