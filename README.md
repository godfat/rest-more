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
* Github
* Instagram [in progress]
* Linkedin
* Twitter

Rails utilities are also included.

## REQUIREMENTS:

### Mandatory:

* MRI (official CRuby) 1.9.3, 2.0.0, Rubinius and JRuby
* gem rest-core
* gem rest-client

### Optional:

* gem [em-http-request][] (if using eventmachine)
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

## EventMachine inside Rainbows!

To be added. But you can take a look at [Rainbows configuration][] first.

[Rainbows configuration]: https://github.com/godfat/rest-more/blob/master/example/rainbows.rb

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

Copyright (c) 2011-2013, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
