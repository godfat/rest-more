# CHANGES

## rest-more 0.7.0 -- 2011-10-08

* Extracted from [rest-core][] 0.4.0
* [Facebook] Added `RC::Facebook#parse_fbsr!` which can parse Facebook's new
  cookie. Also, `RC::Facebook#parse_cookies!` would look for that too.
* [Facebook] Fixed that parsing an invalid signed_request would raise an
  error. From now on it would simply ignore it and wipe out the data.
* [Flurry] Some minor updates.

[rest-core]: https://github.com/cardinalblue/rest-core
