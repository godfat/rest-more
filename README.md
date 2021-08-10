# rest-more [![Build Status](https://secure.travis-ci.org/godfat/rest-more.png?branch=master)](http://travis-ci.org/godfat/rest-more) [![Coverage Status](https://coveralls.io/repos/github/godfat/rest-more/badge.png)](https://coveralls.io/github/godfat/rest-more) [![Join the chat at https://gitter.im/godfat/rest-more](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/godfat/rest-more)

by Lin Jen-Shin ([godfat](http://godfat.org))

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin. There's another talk about [The Promise of rest-core][]

[godfat]: https://github.com/godfat
[talk]: http://rubyconf.tw/2011/#6
[The Promise of rest-core]: http://godfat.org/slide/2015-01-13-rest-core-promise/

## LINKS:

* [github](https://github.com/godfat/rest-more)
* [rubygems](https://rubygems.org/gems/rest-more)
* [rdoc](http://rdoc.info/projects/godfat/rest-more)
* [issues](https://github.com/godfat/rest-more/issues) (feel free to ask for support)

## DESCRIPTION:

Various REST clients such as Facebook and Twitter built with [rest-core][].

[rest-core]: https://github.com/godfat/rest-core

## FEATURES:

Out-of-box REST clients built with rest-core for:

* [RC::Dropbox][] (via OAuth 1.0a)
* [RC::Facebook][] (via OAuth 2, most completed)
* [RC::Github][] (via OAuth 2)
* [RC::Instagram][] (via OAuth 2)
* [RC::Linkedin][] (via OAuth 1.0a)
* [RC::StackExchange][] (via OAuth 2)
* [RC::Twitter][] (via OAuth 1.0a)

[RC::Dropbox]: lib/rest-core/client/dropbox.rb
[RC::Facebook]: lib/rest-core/client/facebook.rb
[RC::Github]: lib/rest-core/client/github.rb
[RC::Instagram]: lib/rest-core/client/instagram.rb
[RC::Linkedin]: lib/rest-core/client/linkedin.rb
[RC::StackExchange]: lib/rest-core/client/stackexchange.rb
[RC::Twitter]: lib/rest-core/client/twitter.rb

Rails utilities are also included for some clients.

Other clients in other gems:

* Firebase: [rest-firebase][]
* TopCoder: [topcoder][]
* YahooBuy: [rest-more-yahoo_buy][]
* Scrapyd: [rest-scrapyd][]

[rest-firebase]: https://github.com/CodementorIO/rest-firebase
[topcoder]: https://github.com/miaout17/topcoder
[rest-more-yahoo_buy]: https://github.com/GoodLife/rest-more-yahoo_buy
[rest-scrapyd]: https://github.com/wvengen/rest-scrapyd

## REQUIREMENTS:

### Mandatory:

* Tested with MRI (official CRuby) and JRuby.
* gem [rest-core][]
* gem [httpclient][]
* gem [mime-types][]
* gem [timers][]

[httpclient]: https://github.com/nahi/httpclient
[mime-types]: https://github.com/halostatue/mime-types
[timers]: https://github.com/celluloid/timers

### Optional:

* gem json or yajl-ruby, or multi_json (if `JsonResponse` or
  `JsonRequest` middlewares are used)

## INSTALLATION:

``` shell
gem install rest-more
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'rest-more', :git => 'git://github.com/godfat/rest-more.git',
                 :submodules => true
```

## SYNOPSIS:

### Dropbox example:

Check out their
[API documentation](https://www.dropbox.com/developers/reference/api)
for a complete reference, and [RC::Dropbox][] for built-in APIs.

``` ruby
require 'rest-more'

d = RC::Dropbox.new :root => 'sandbox',
                    :consumer_key => 'key',
                    :consumer_secret => 'secret',
                    :log_method => method(:puts)

# Redirect the user to:
d.authorize_url!

# After the user authorized, then we can do this to obtain the access token:
d.authorize!

# Then we could call the API:
p [d.me, d.ls]
```

### Facebook example:

Check out their
[Graph API documentation](https://developers.facebook.com/docs/graph-api/reference/v2.0/)
for a complete reference, and [RC::Facebook][] for built-in APIs.
[RC::Facebook::RailsUtil][] for Facebook is also available.

[RC::Facebook::RailsUtil]: lib/rest-core/client/facebook/rails_util.rb

``` ruby
require 'rest-more'

f = RC::Facebook.new :app_id => '123',
                     :secret => 'secret',
                     :access_token => 'if you have the token',
                     :log_method => method(:puts)

redirect_uri = 'http://example.com'
scope = 'public_profile,email'

# Redirect the user to:
f.authorize_url(:redirect_uri => redirect_uri, :scope => scope)

# After the user authorized, then we can do this to obtain the access token:
f.authorize!(:redirect_uri => redirect_uri, :code => 'code')

# Then we could call the API:
p [f.me, f.get('me/posts')]
```

### Github example:

Check out their
[API documentation](https://developer.github.com/v3/)
for a complete reference, and [RC::Github][] for built-in APIs.

``` ruby
require 'rest-more'

g = RC::Github.new :access_token => 'if you have the token',
                   :log_method => method(:puts)

p [g.me, g.get('users/godfat')]
p g.all('users/godfat/repos').size # get all repositories across all pages

```

### Instagram example:

Check out their
[Developer documentation](http://instagram.com/developer/)
for a complete reference, and [RC::Instagram][] for built-in APIs.

``` ruby
require 'rest-more'

i = RC::Instagram.new :client_id => 'id',
                      :client_secret => 'secret',
                      :log_method => method(:puts)

redirect_uri = 'http://example.com'

# Redirect the user to:
i.authorize_url(:redirect_uri => redirect_uri)

# After the user authorized, then we can do this to obtain the access token:
i.authorize!(:redirect_uri => redirect_uri, :code => 'code')

# Then we could call the API:
p i.me
```

### Linkedin example:

Check out their
[API documentation](http://developer.linkedin.com/documents/linkedin-api-resource-map)
for a complete reference, and [RC::Linkedin][] for built-in APIs.

``` ruby
require 'rest-more'

l = RC::Linkedin.new :consumer_key => 'key',
                     :consumer_secret => 'secret',
                     :log_method => method(:puts)

# Redirect the user to:
l.authorize_url!

# After the user authorized, then we can do this to obtain the access token:
l.authorize!(:oauth_verifier => 'oauth_verifier')

# Then we could call the API:
p l.me
```

### Twitter example:

Check out their
[REST API documentation](https://dev.twitter.com/docs/api/1.1)
for a complete reference, and [RC::Twitter][] for built-in APIs.

``` ruby
require 'rest-more'

t = RC::Twitter.new :consumer_key => 'key',
                    :consumer_secret => 'secret',
                    :log_method => method(:puts)

# Redirect the user to:
t.authorize_url!

# After the user authorized, then we can do this to obtain the access token:
t.authorize!(:oauth_token => 'oauth_token',
             :oauth_verifier => 'oauth_verifier')

# Then we could call the API:
p [t.me, t.statuses('godfat')]
p t.tweet('Aloha!', File.open('screen.png')) # Image is optional
```

### Example codes:

Runnable example is at: [example/simple.rb][]. Please see [slides][] from
[rubyconf.tw/2011][rubyconf.tw] for concepts.

[example/simple.rb]: https://github.com/godfat/rest-more/blob/master/example/simple.rb
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html
[rubyconf.tw]: http://rubyconf.tw/2011/#6

## Concurrent HTTP Requests:

Inherited from [rest-core][], you can do concurrent requests quite easily.
Here's a very quick example of getting Facebook users' names for UID 4 and 5:

``` ruby
require 'rest-more'
facebook = RC::Facebook.new(:log_method => method(:puts))
puts "httpclient with threads doing concurrent requests"
a = [facebook.get('4'), facebook.get('5')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"
```

If you prefer callback based solution, this would also work:

``` ruby
require 'rest-more'
facebook = RC::Facebook.new(:log_method => method(:puts))
puts "callback also works"
facebook.get('6') do |r|
  p r['name']
end
puts "It's not blocking... but doing concurrent requests underneath"
facebook.wait # we block here to wait for the request done
puts "DONE"
```

Runnable example is at: [example/multi.rb][]. For a detailed demonstration,
see: [Advanced Concurrent HTTP Requests -- Embrace the Future][future]

[example/multi.rb]: https://github.com/godfat/rest-more/blob/master/example/multi.rb
[future]: https://github.com/godfat/rest-core#advanced-concurrent-http-requests----embrace-the-future

## Rails Utilities

To be added. But you can take a look at [Facebook tutorial][] first.

[Facebook tutorial]: doc/facebook.md

## A simple interactive shell with [rib][]:

You need to install [rib][] in order to try this interactive shell:

    gem install rib

Then you can try this by running `rib rest-core`:

    rest-core>> self.site = 'https://api.github.com/users/'
    rest-core>> self.json_response = true
    rest-core>> get 'godfat'

Which is using `RestCore::Universal` for accessing arbitrary websites.

[rib]: https://github.com/godfat/rib

## rest-more users:

* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)

## Powered sites:

* [Codementor](https://www.codementor.io/)
* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](CHANGES.md)

## CONTRIBUTORS:

* ayaya (@ayamomiji)
* Fumin (@fumin)
* khoa nguyen (@khoan)
* Lin Jen-Shin (@godfat)
* Yun-Yan Chi (@jaiyalas)

## LICENSE:

Apache License 2.0 (Apache-2.0)

Copyright (c) 2011-2021, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
