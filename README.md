# rest-more [![Build Status](https://secure.travis-ci.org/godfat/rest-more.png?branch=master)](http://travis-ci.org/godfat/rest-more)

by Lin Jen-Shin ([godfat](http://godfat.org))

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin.

[godfat]: https://github.com/godfat
[talk]: http://rubyconf.tw/2011/#6

## LINKS:

* [github](https://github.com/godfat/rest-more)
* [rubygems](https://rubygems.org/gems/rest-more)
* [rdoc](http://rdoc.info/projects/godfat/rest-more)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

Various REST clients such as Facebook and Twitter built with [rest-core][].

[rest-core]: https://github.com/godfat/rest-core

## FEATURES:

Out-of-box REST clients built with rest-core for:

* Dropbox
* Facebook
* Firebase
* Github
* Instagram
* Linkedin
* Twitter

Rails utilities are also included.

## REQUIREMENTS:

### Mandatory:

* Tested with MRI (official CRuby), Rubinius and JRuby.
* gem rest-core
* gem httpclient
* gem timers

### Optional:

* gem json or yajl-ruby, or multi_json (if `JsonResponse` or
  `JsonRequest` middlewares are used)

[em-http-request]: https://github.com/igrigorik/em-http-request

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
for a complete reference, and [RC::Dropbox](lib/rest-core/client/dropbox.rb)
for built-in APIs.

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
p d.me
p d.ls
```

### Facebook example:

Check out their
[Graph API documentation](https://developers.facebook.com/docs/graph-api/reference/v2.0/)
for a complete reference, and [RC::Facebook](lib/rest-core/client/facebook.rb)
for built-in APIs.

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
p f.me
p f.get('me/posts')
```

### Firebase example:

Check out their
[REST API documentation](https://www.firebase.com/docs/rest-api.html)
for a complete reference, and [RC::Firebase](lib/rest-core/client/firebase.rb)
for built-in APIs.

``` ruby
require 'rest-more'

f = RC::Firebase.new :site => 'https://example.firebaseio.com/',
                     :secret => 'secret',
                     :d => {:auth_data => 'something'},
                     :log_method => method(:puts)

# Listen on test.json
es = f.event_source('test')
es.onopen{ |sock| p sock }
es.onmessage{ |event| p event }
es.onerror{ |error| p error }
es.start

# Updating test.json
p f.put('test', :some => 'data')
p f.post('test', :some => 'other')
p f.get('test')
p f.delete('test')
```

### Github example:

Check out their
[API documentation](https://developer.github.com/v3/)
for a complete reference, and [RC::Github](lib/rest-core/client/github.rb)
for built-in APIs.

``` ruby
require 'rest-more'

g = RC::Github.new :access_token => 'if you have the token',
                   :log_method => method(:puts)

p g.me
p g.get('users/godfat')
```

### Instagram example:

### Linkedin example:

### Twitter example:

``` ruby
require 'rest-more'

t = RC::Twitter.new :consumer_key => 'key',
                    :consumer_secret => 'secret',
                    :log_method => method(:puts)

# Redirect the user to:
d.authorize_url!

# After the user authorized, then we can do this to obtain the access token:
d.authorize!(:oauth_token => 'oauth_token',
             :oauth_verifier => 'oauth_verifier')

# Then we could call the API:
p t.me
p t.statuses('godfat')
p t.tweet('Aloha!', File.open('screen.png')) # Image is optional
```

Runnable example is at: [example/simple.rb][]. Please see [slides][] from
[rubyconf.tw/2011][rubyconf.tw] for concepts.

[example/simple.rb]: https://github.com/godfat/rest-more/blob/master/example/simple.rb
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html
[rubyconf.tw]: http://rubyconf.tw/2011/#6

## Concurrent HTTP Requests:

Inherited from rest-core, you can do concurrent requests quite easily.
Here's a very quick example of getting Facebook users' names for UID 4 and 5:

``` ruby
require 'rest-more'
facebook = RC::Facebook.new(:log_method => method(:puts))
puts "rest-client with threads doing concurrent requests"
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
facebook.get('6'){ |r|
  p r['name']
}
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

[Facebook tutorial]: https://github.com/godfat/rest-more/blob/master/doc/tutorial/facebook.md

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

* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](https://github.com/godfat/rest-more/blob/master/CHANGES.md)

## CONTRIBUTORS:

* ayaya (@ayamomiji)
* Fumin (@fumin)
* khoa nguyen (@khoan)
* Lin Jen-Shin (@godfat)
* Yun-Yan Chi (@jaiyalas)

## LICENSE:

Apache License 2.0

Copyright (c) 2011-2014, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
