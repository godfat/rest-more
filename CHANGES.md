# CHANGES

## rest-more 0.8 -- ?

### Incompatible changes

* [Facebook::RailsUtil] Some methods are renamed. For example,
  `rc_facebook_write_rg_fbs` is renamed to `rc_facebook_write_fbs`.
  All renamed methods are considered private, so we're not listing them here.

* [Facebook::RailsUtil] `rc_facebook_storage_key` is changed to:
  `"rc_facebook_#{rc_facebook.app_id}"`, your users might need to
  login again in order to save the access_token into the new place.

### Bugs fixes

* [Github] Fixed usage of Oauth2Query.

* [Facebook] Now we're using POST in `authorize!` to exchange the
  access_token with the code instead of GET. If we're using GET,
  we would run into a risk where a user might use the code to
  get other people's access_token via the cache. Using POST would
  prevent this because POSTs are not cached.

* [Facebook::RailsUtil] Fixed a serious bug. The bug would jump up if
  you're using :write_session or :write_cookies or :write_handler along
  with :auto_authorize, for example:
  `rc_facebook_setup(:auto_authorize => true, :write_session => true)`
  The problem is that Facebook::RailsUtil is not removing the invalid
  access_token stored in session or cookie, and yet it is considered
  authorized, making redirecting to Facebook and redirecting back doesn't
  update the access_token. `rc_facebook_cleanup` is introduced to remove
  all invalid access_tokens, which would get called once the user is
  redirected to Facebook, fixing this bug.

### Enhancement

* [Facebook] Now we use `default_data` to get the default data,
  instead of relying `Defaults` middleware.

* [Facebook] Protected methods are changed to private.

* [Flurry] `app_info` now accepts opts.
* [Flurry] `event_metrics` is renamed to `event_summary`
* [Flurry] `event_metrics` is now the API for accessing 'eventMetrics/Event'
* [Flurry] If you didn't pass dates, now default to for 7 days.

* [Linkedin+Twitter] Removed `Defaults` middleware because now we're using
  the data from `Oauth1Client` instead.

* [Linkedin+Twitter] Removed `oauth_token`, `oauth_token=`,
  `oauth_token_secret`, and `oauth_token_secret=` because we're using them
  from `Oauth1Client` instead.

* [Linkedin+Twitter] Removed `set_token` because it's handled in
  `Oauth1Client` now.

* [Twitter::RailsUtil] Now `rc_twitter_setup` accepts options like
  `rc_facebook_setup`: `auto_authorize`, `ensure_authorized`,
  `write_session`, `write_cookies`, `write_handler`, and `check_handler`.

* [Mixi] Removed `Defaults` middleware in favor of `default_data`.

* [Facebook+Github+Mixi+Twitter] Added a `me` method for accessing current
  user information.

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
