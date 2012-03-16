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

* Bing
* Dropbox
* Facebook
* Flurry
* Github
* Linkedin
* Mixi
* Twitter

Rails utilities are also included.

## REQUIREMENTS:

### Mandatory:

* MRI (official CRuby) 1.8.7, 1.9.2, 1.9.3, Rubinius 1.8/1.9 and JRuby 1.8/1.9
* gem rest-client

### Optional:

* Fibers only work on Ruby 1.9+
* gem [em-http-request][] (if using eventmachine)
* gem [cool.io-http][] (if using cool.io)
* gem json or yajl-ruby (if using JsonDecode middleware)

[em-http-request]: https://github.com/igrigorik/em-http-request
[cool.io-http]: https://github.com/godfat/cool.io-http

## INSTALLATION:

    gem install rest-more

Or if you want development version, put this in Gemfile:

``` ruby
    gem 'rest-more', :git => 'git://github.com/cardinalblue/rest-more.git',
                     :submodules => true
```

## SYNOPSIS:

``` ruby
    require 'rest-more'

    RestCore::Twitter.new.statuses('_cardinalblue') # get user tweets
    RestCore::Github.new.get('users/cardinalblue')  # get user info

    linkedin = RestCore::Linkedin.new(:consumer_key    => '...',
                                      :consumer_secret => '...')
    linkedin.authorize_url!   # copy and paste the URL in browser to authorize
    linkedin.authorize!('..') # paste your code from browser
    linkedin.me               # get current user info

    RestCore::Facebook.new.get('4') # get user info
```

See [example][] for more complex examples.

[example]: https://github.com/cardinalblue/rest-more/tree/master/example

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
