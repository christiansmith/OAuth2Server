# ID Token Specs
# per http://openid.net/specs/openid-connect-core-1_0.html#IDToken

describe 'ID Token', ->

  describe 'schema', ->

    it 'should require an "iss" claim'
    it 'should require a "sub" claim'
    it 'should require an "aud" claim'
    it 'should require an "exp" claim'
    it 'should require an "iat" claim'
    it 'should have an "auth_time" claim'
    it 'should have a "nonce"'
    it 'may have an "acr" claim'
    it 'may have an "amr" claim'
    it 'may have an "azp" claim'


  describe 'initialization', ->

    it 'must ignore claims that are not defined by OpenID Connect Core'


  describe 'serialization', ->

    it 'should result in a JWT'
    it 'should sign the token with JWS'
    it 'may encrypt the signed token with JWE'
