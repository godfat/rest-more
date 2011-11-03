# rest-more [![Build Status](http://travis-ci.org/godfat/rest-more.png)](http://travis-ci.org/godfat/rest-more)

by Cardinal Blue <http://cardinalblue.com>

## LINKS:

* [github](https://github.com/cardinalblue/rest-more)
* [rubygems](http://rubygems.org/gems/rest-more)
* [rdoc](http://rdoc.info/projects/cardinalblue/rest-more)
* [mailing list](http://groups.google.com/group/rest-core/topics)

## DESCRIPTION:

Various REST clients such as Facebook and Twitter built with [rest-core][]

[rest-core]: https://github.com/cardinalblue/rest-core

## REQUIREMENTS:

* Tested with MRI (official CRuby) 1.8.7, 1.9.2, 1.9.3, Rubinius and JRuby
* gem install rest-core

## INSTALLATION:

    gem install rest-more

Or if you want development version, put this in Gemfile:

    gem 'rest-more', :git => 'git://github.com/cardinalblue/rest-more.git',
                     :submodules => true

## SYNOPSIS:

    require 'rest-more'

    RestCore::Twitter.new.statuses('_cardinalblue') # get user tweets
    RestCore::Github.new.get('users/cardinalblue')  # get user info

    linkedin = RestCore::Linkedin.new(:consumer_key    => '...',
                                      :consumer_secret => '...')
    linkedin.authorize_url!   # copy and paste the URL in browser to authorize
    linkedin.authorize!('..') # paste your code from browser
    linkedin.me               # get current user info

    RestCore::Facebook.new.get('4') # get user info

See [example][] for more complex examples.

[example]: https://github.com/cardinalblue/rest-more/tree/master/example

## A simple interactive shell with [rib][]:

You need to install [rib][] in order to try this interactive shell:

    gem install rib

Then you can try this by running `rib rest-core`:

    rest-core>> self.site = 'https://api.github.com/users/'
    rest-core>> get 'cardinalblue', {}, :json_decode => true

Which is using `RestCore::Universal` for accessing arbitrary websites.

[rib]: https://github.com/godfat/rib

## rest-more users:

* [s2sync](https://github.com/brucehsu/s2sync)
* [s2sync_web](https://github.com/brucehsu/s2sync_web)

## LICENSE:

Apache License 2.0

Copyright (c) 2011, Cardinal Blue

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
