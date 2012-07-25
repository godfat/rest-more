# rest-more [![Build Status](https://secure.travis-ci.org/godfat/rest-more.png?branch=master)](http://travis-ci.org/godfat/rest-more)

by Cardinal Blue <http://cardinalblue.com>

Lin Jen-Shin ([godfat][]) had given a talk about rest-core on
[RubyConf Taiwan 2011][talk]. The slide is in English, but the
talk is in Mandarin.

You can also read some other topics at [doc](https://github.com/cardinalblue/rest-core/blob/master/doc/ToC.md).

[godfat]: https://github.com/godfat
[talk]: http://rubyconf.tw/2011/#6

## LINKS:

* [github](https://github.com/cardinalblue/rest-more)
* [rubygems](https://rubygems.org/gems/rest-more)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-more)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

Various REST clients such as Facebook and Twitter built with [rest-core][]

[rest-core]: https://github.com/cardinalblue/rest-core

## FEATURES:

Out-of-box REST clients built with rest-core for:

* Dropbox
* Facebook
* Github
* Linkedin
* Twitter

Rails utilities are also included.

## REQUIREMENTS:

### Mandatory:

* MRI (official CRuby) 1.9.2, 1.9.3, Rubinius 1.9 and JRuby 1.9
* gem rest-client

### Optional:

* gem [em-http-request][] (if using eventmachine)
* gem json or yajl-ruby, or multi_json (if using `JsonDecode` middleware)

[em-http-request]: https://github.com/igrigorik/em-http-request

## INSTALLATION:

``` shell
    gem install rest-more
```

Or if you want development version, put this in Gemfile:

``` ruby
    gem 'rest-more', :git => 'git://github.com/cardinalblue/rest-more.git',
                     :submodules => true
```

## SYNOPSIS:

The simplest usage:

``` ruby
    require 'rest-more'

    RC::Twitter.new.statuses('_cardinalblue') # get user tweets
    RC::Github.new.get('users/cardinalblue')  # get user info

    linkedin = RC::Linkedin.new(:consumer_key    => '...',
                                :consumer_secret => '...')
    linkedin.authorize_url!   # copy and paste the URL in browser to authorize
    linkedin.authorize!('..') # paste your code from browser
    linkedin.me               # get current user info

    RC::Facebook.new.get('4') # get user info
```

Runnable example is here: [example/simple.rb][]. Please see [slides][] from
[rubyconf.tw/2011][rubyconf.tw] for concepts.

[example/simple.rb]: https://github.com/cardinalblue/rest-more/blob/master/example/simple.rb
[slides]: http://www.godfat.org/slide/2011-08-27-rest-core.html
[rubyconf.tw]: http://rubyconf.tw/2011/#6

## Asynchronous HTTP Requests:

I/O bound operations shouldn't be blocking the CPU! If you have a reactor,
i.e. event loop, you should take the advantage of that to make HTTP requests
not block the whole process/thread. For now, we support eventmachine.
Hopefully [celluloid-io][] in the future. By default, all clients are using
`Auto`, which would detect the context automatically, and choose to use
`RestClient`, a synchronous HTTP client, thus blocking. Or `EmHttpRequest`,
a asynchronous HTTP client, thus non-blocking.

It's very easy to use, but not
very scalable (not concurrent-efficient). You can change the default app
(i.e. HTTP clients) to an asynchronous one:

[celluloid-io]: https://github.com/tarcieri/celluloid-io

``` ruby
    require 'rest-more'
    RC::Builder.default_app = RC::EmHttpRequest
```

or an auto-picking one, which would try to infer the correct HTTP client
depending on the context. Either em-http-request, cool.io-http, or even
rest-client if none of reactors is available.

``` ruby
    require 'rest-more'
    RC::Builder.default_app = RC::Auto
```

You can also setup the `default_app` for a specific client, so that it won't
change all the `default_app` for all the clients, like this:

``` ruby
    require 'rest-more'
    RC::Facebook.builder.default_app = RestCore::Auto
```

If you're passing a block, the block is called after the response is
available. That is the block is the callback for the request.

``` ruby
    require 'rest-more'
    require 'eventmachine'
    RC::Builder.default_app = RC::EmHttpRequest
    EM.run{
      RC::Facebook.new.get('4'){ |response|
        p response
        EM.stop
      }
      puts "It's not blocking..."
    }
```

Otherwise, if you don't pass a block as the callback, EmHttpRequest (i.e.
the HTTP client for eventmachine) would call `Fiber.yield` to yield to the
original fiber, making asynchronous HTTP requests look like synchronous.
If you don't understand what does this mean, you can take a look at
[em-synchrony][]. It's basically the same idea.

``` ruby
    require 'rest-more'
    require 'eventmachine'

    RC::Builder.default_app = RC::EmHttpRequest

    EM.run{
      Fiber.new{
        p RestCore::Facebook.new.get('4')
        EM.stop
      }.resume
      puts "It's not blocking..."
    }
```

[em-synchrony]: https://github.com/igrigorik/em-synchrony

Runnable example is here: [example/facebook.rb][].
You can also make multi-requests synchronously like this:

``` ruby
    require 'rest-more'
    require 'eventmachine'

    RC::Builder.default_app = RC::Auto
    facebook = RC::Facebook.new(:log_method => method(:puts))

    EM.run{
      Fiber.new{
        fiber = Fiber.current
        result = {}
        facebook.get('4'){ |response|
          result[0] = response
          fiber.resume(result) if result.size == 2
        }
        puts "It's not blocking..."
        facebook.get('4'){ |response|
          result[1] = response
          fiber.resume(result) if result.size == 2
        }
        p Fiber.yield
        EM.stop
      }.resume
      puts "It's not blocking..."
    }
```

Runnable example is here: [example/multi.rb][]. All `RestCore::EmHttpRequest`
above is interchangeable with `RestCore::Auto` because `RestCore::Auto` would
pick the right HTTP client when running inside the eventmachine's event loop.

[example/facebook.rb]: https://github.com/cardinalblue/rest-more/blob/master/example/facebook.rb
[example/multi.rb]: https://github.com/cardinalblue/rest-more/blob/master/example/multi.rb

## Supported HTTP clients:

* `RestCore::RestClient` (gem rest-client)
* `RestCore::EmHttpRequest` (gem em-http-request)
* `RestCore::Auto` (which would pick one of the above depending on the
  context)

## Rails Utilities

To be added. But you can take a look at the [Facebook tutorial][] first.

[Facebook tutorial]: https://github.com/cardinalblue/rest-more/blob/master/doc/tutorial/facebook.md

## EventMachine inside Rainbows!

To be added. But you can take a look at the [Rainbows configuration][] first.

[Rainbows configuration]: https://github.com/cardinalblue/rest-more/blob/master/example/rainbows.rb

## A simple interactive shell with [rib][]:

You need to install [rib][] in order to try this interactive shell:

    gem install rib

Then you can try this by running `rib rest-core`:

    rest-core>> self.site = 'https://api.github.com/users/'
    rest-core>> self.json_decode = true
    rest-core>> get 'cardinalblue'

Which is using `RestCore::Universal` for accessing arbitrary websites.

[rib]: https://github.com/godfat/rib

## rest-more users:

* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)

## Powered sites:

* [PicCollage](http://pic-collage.com/)

## CHANGES:

* [CHANGES](https://github.com/cardinalblue/rest-more/blob/master/CHANGES.md)

## CONTRIBUTORS:

* ayaya (@ayamomiji)
* Lin Jen-Shin (@godfat)
* Yun-Yan Chi (@jaiyalas)

## LICENSE:

Apache License 2.0

Copyright (c) 2011-2012, Cardinal Blue

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
