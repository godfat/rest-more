# CHANGES

## rest-more 0.7.2.1 -- 2011-11-05

### Bugs fixes

* [Facebook::RailsUtil] Fixed a missed change which should be made.

## rest-more 0.7.2 -- 2011-11-05

### Incompatible changes

* [Flurry] renamed `api_key` to `apiKey` to better match the original name
  from flurry. Also renamed `access_code` to `apiAccessCode`.
* [Facebook::RailsUtil] Some `module_function`s are changed to controller's
  private methods. You aren't using it if you don't know what does this mean.

### Enhancement

* Added `rib-rest-core` command line tool, extracted from rest-core.
* [RailsUtilUtil] Introduced this to ease the pain writing RailsUtil for
  various clients.
* [Bing] Added Bing client and its RailsUtil.
* [Github] Added RailsUtil for Github client.
* [Linkedin] Added RailsUtil for Linkedin client.
* [Mixi] Added RailsUtil for Mixi client.
* [Twitter] Added RailsUtil for Twitter client.

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
