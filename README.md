# OAuth2Server

## Project Goals

Where most OAuth-related packages provide middleware or toolkits for implementing an authorization server, this project aims to deliver a ready-to-deploy server that can be incorporated out-of-the-box into a distributed architecture, along with a collection of SDKs for using it within client applications and API services. This won't be right for everyone, so it's great to have options like [nightworld](https://github.com/nightworld)'s [node-oauth2-server](https://npmjs.org/package/node-oauth2-server) and [jaredhanson](https://github.com/jaredhanson)'s [oauth2orize](https://github.com/jaredhanson/oauth2orize).

There are currently three major use cases we intend to support:

1. Centralized user account management and authentication for trusted client applications
2. Third party API access as an OAuth 2.0 provider
3. Single sign on


## How to Participate

* Come to the [Google Hangout](http://bit.ly/Auth2Hangout) at 10am Pacific every Thursday, where we review code, brainstorm, and talk shop. 
* If you want to contribute specific features, please submit an issue describing your proposed enhancements *first*, so we can avoid duplicating efforts.
* Pair program with the author. Just email [christiansmith](https://github.com/christiansmith) to arrange a time.


## Related Projects

* [OAuth2Resource](https://github.com/christiansmith/OAuth2Resource) provides Express middleware for authorizing access to resource servers protected by OAuth2Server.


## The MIT License

Copyright (c) 2013 Christian Smith http://anvil.io

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
