# CHANGES

## rest-more 0.7.1 -- 2011-10-31

### Bugs fixes

* [Mixi] Fixed `RC::Mixi.new(:access_token => 'access_token')` which is not
  working before.

### Enhancement

* [Mixi] `RC::Mixi#authorize!` now works like `RC::Facebook#authorize!`
  That is now we pass code like this: `mixi.authorize!(:code => code)`

* `RestCore::Config` and `RestCore::RailsUtilUtil` are now moved to rest-more

## rest-more 0.7.0 -- 2011-10-08

* Extracted from [rest-core][] 0.4.0
* [Facebook] Added `RC::Facebook#parse_fbsr!` which can parse Facebook's new
  cookie. Also, `RC::Facebook#parse_cookies!` would look for that too.
* [Facebook] Fixed that parsing an invalid signed_request would raise an
  error. From now on it would simply ignore it and wipe out the data.
* [Flurry] Some minor updates.

[rest-core]: https://github.com/cardinalblue/rest-core
