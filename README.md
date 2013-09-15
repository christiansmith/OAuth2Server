# OAuth2Server

## Project Goals

Most OAuth-related packages provide middleware or toolkits for implementing an authorization server. This project aims to deliver a complete, standalone, ready-to-deploy authorization server that can be incorporated out-of-the-box into a distributed architecture, along with a collection of SDKs for using it within client apps and API services. This won't be right for everyone, so it's great to have options like [nightworld](https://github.com/nightworld)'s [node-oauth2-server](https://npmjs.org/package/node-oauth2-server) and [jaredhanson](https://github.com/jaredhanson)'s [oauth2orize](https://github.com/jaredhanson/oauth2orize).

There are currently three major use cases we intend to support:

1. Centralized user account management and authentication for trusted client applications
2. Third party API access as an OAuth 2.0 provider
3. Single sign on

## Using OAuth2Server

You can get the code by cloning this respository. It will be available by package manager as we get closer to a stable release.

    $ git clone https://github.com/christiansmith/OAuth2Server.git

[API docs](https://github.com/christiansmith/OAuth2Server/wiki/API) are in the wiki. We're developing fast and this may be out of sync with the code. Please [post an issue](https://github.com/christiansmith/OAuth2Server/issues) if you have questions about usage. 


## How to Participate

We want to both *build the right thing* and *build the thing right*.

* Help us *build the right thing* by coming to the [Google Hangout](http://bit.ly/Auth2Hangout) at 10am Pacific every Thursday to brainstorm features and use cases. We love to hear from prospective users.
* To help us *build the thing right*:
  * **Post and comment** on [issues](https://github.com/christiansmith/OAuth2Server/issues). This is the best place to discuss/debate implementation details, point out bugs, flaws, and security issues. 
  * **Fork and request pulls** for features and bug fixes. For substantial features, please [submit an issue](https://github.com/christiansmith/OAuth2Server/issues) describing your proposed enhancements *first*, so we can avoid duplicating efforts.
  * **Pair program**. These sessions are always fun and productive. Send me an email to arrange a time (smith at anvil dot io). 
* Stay up to date by watching this repository, reading the [project blog](http://oauth2server.blogspot.com/) and checking the [issues](https://github.com/christiansmith/OAuth2Server/issues).
* Promote the project and help us find more early users by blogging, tweeting, +1-ing, starring, gossiping and anything else you think might help.


## Sponsorship

Accelerate development of features you need by sponsoring the project. Email for more info (smith at anvil dot io).


## Related Projects

* [OAuth2Resource](https://github.com/christiansmith/OAuth2Resource) provides Express middleware for authorizing access to resource servers protected by OAuth2Server.
* [Modinha](https://github.com/christiansmith/Modinha) Schema-based data modeling with swappable storage adapters. Extracted from OAuth2Server
* [Milonga](https://github.com/christiansmith/Milonga) Milonga is a helper for defining a set of RESTful Express routes based on Modinha models. Developed for use in OAuth2Server


## Acknowledgements

Thanks to [Ben Dalton](https://github.com/bendalton), [Tom Kersten](https://github.com/tomkersten), and everyone who's contributed to requirements, reviewed code, provided encouragement, expressed interest, made time to discuss the project, and otherwise helped to keep us on track! Thanks to [Ward Cunningham](https://github.com/WardCunningham) for inspiring the weekly hangout!


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
