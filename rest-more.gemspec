# -*- encoding: utf-8 -*-
# stub: rest-more 3.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rest-more".freeze
  s.version = "3.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lin Jen-Shin (godfat)".freeze]
  s.date = "2018-03-20"
  s.description = "Various REST clients such as Facebook and Twitter built with [rest-core][].\n\n[rest-core]: https://github.com/godfat/rest-core".freeze
  s.email = ["godfat (XD) godfat.org".freeze]
  s.executables = ["rib-rest-core".freeze]
  s.files = [
  ".gitignore".freeze,
  ".gitmodules".freeze,
  ".travis.yml".freeze,
  "CHANGES.md".freeze,
  "Gemfile".freeze,
  "LICENSE".freeze,
  "README.md".freeze,
  "Rakefile".freeze,
  "TODO.md".freeze,
  "bin/rib-rest-core".freeze,
  "doc/facebook.md".freeze,
  "example/multi.rb".freeze,
  "example/simple.rb".freeze,
  "example/sinatra/config.ru".freeze,
  "lib/rest-core/client/dropbox.rb".freeze,
  "lib/rest-core/client/facebook.rb".freeze,
  "lib/rest-core/client/facebook/rails_util.rb".freeze,
  "lib/rest-core/client/github.rb".freeze,
  "lib/rest-core/client/github/rails_util.rb".freeze,
  "lib/rest-core/client/instagram.rb".freeze,
  "lib/rest-core/client/linkedin.rb".freeze,
  "lib/rest-core/client/linkedin/rails_util.rb".freeze,
  "lib/rest-core/client/stackexchange.rb".freeze,
  "lib/rest-core/client/twitter.rb".freeze,
  "lib/rest-core/client/twitter/rails_util.rb".freeze,
  "lib/rest-core/util/rails_util_util.rb".freeze,
  "lib/rest-more.rb".freeze,
  "lib/rest-more/test.rb".freeze,
  "lib/rest-more/version.rb".freeze,
  "lib/rib/app/rest-core.rb".freeze,
  "rest-more.gemspec".freeze,
  "task/README.md".freeze,
  "task/gemgem.rb".freeze,
  "test/dropbox/test_dropbox.rb".freeze,
  "test/facebook/test_api.rb".freeze,
  "test/facebook/test_default.rb".freeze,
  "test/facebook/test_error.rb".freeze,
  "test/facebook/test_handler.rb".freeze,
  "test/facebook/test_misc.rb".freeze,
  "test/facebook/test_oauth.rb".freeze,
  "test/facebook/test_old.rb".freeze,
  "test/facebook/test_page.rb".freeze,
  "test/facebook/test_parse.rb".freeze,
  "test/facebook/test_serialize.rb".freeze,
  "test/facebook/test_timeout.rb".freeze,
  "test/github/test_github.rb".freeze,
  "test/instagram/test_instagram.rb".freeze,
  "test/stackexchange/test_stackexchange.rb".freeze,
  "test/twitter/test_twitter.rb".freeze]
  s.homepage = "https://github.com/godfat/rest-more".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Various REST clients such as Facebook and Twitter built with [rest-core][].".freeze
  s.test_files = [
  "test/dropbox/test_dropbox.rb".freeze,
  "test/facebook/test_api.rb".freeze,
  "test/facebook/test_default.rb".freeze,
  "test/facebook/test_error.rb".freeze,
  "test/facebook/test_handler.rb".freeze,
  "test/facebook/test_misc.rb".freeze,
  "test/facebook/test_oauth.rb".freeze,
  "test/facebook/test_old.rb".freeze,
  "test/facebook/test_page.rb".freeze,
  "test/facebook/test_parse.rb".freeze,
  "test/facebook/test_serialize.rb".freeze,
  "test/facebook/test_timeout.rb".freeze,
  "test/github/test_github.rb".freeze,
  "test/instagram/test_instagram.rb".freeze,
  "test/stackexchange/test_stackexchange.rb".freeze,
  "test/twitter/test_twitter.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
    else
      s.add_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rest-core>.freeze, [">= 4.0.0"])
  end
end
