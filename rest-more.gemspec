# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rest-more"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  "Cardinal Blue",
  "Lin Jen-Shin (godfat)"]
  s.date = "2012-02-19"
  s.description = "Various REST clients such as Facebook and Twitter built with [rest-core][]\n\n[rest-core]: https://github.com/cardinalblue/rest-core"
  s.email = ["dev (XD) cardinalblue.com"]
  s.executables = ["rib-rest-core"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  ".travis.yml",
  "CHANGES.md",
  "Gemfile",
  "LICENSE",
  "README.md",
  "Rakefile",
  "TODO.md",
  "bin/rib-rest-core",
  "example/async.rb",
  "example/rails2/Gemfile",
  "example/rails2/README",
  "example/rails2/Rakefile",
  "example/rails2/app/controllers/application_controller.rb",
  "example/rails2/app/views/application/helper.html.erb",
  "example/rails2/config/boot.rb",
  "example/rails2/config/environment.rb",
  "example/rails2/config/environments/development.rb",
  "example/rails2/config/environments/production.rb",
  "example/rails2/config/environments/test.rb",
  "example/rails2/config/initializers/cookie_verification_secret.rb",
  "example/rails2/config/initializers/new_rails_defaults.rb",
  "example/rails2/config/initializers/session_store.rb",
  "example/rails2/config/preinitializer.rb",
  "example/rails2/config/rest-core.yaml",
  "example/rails2/config/routes.rb",
  "example/rails2/log",
  "example/rails2/test/functional/application_controller_test.rb",
  "example/rails2/test/test_helper.rb",
  "example/rails2/test/unit/rails_util_test.rb",
  "example/rails3/Gemfile",
  "example/rails3/README",
  "example/rails3/Rakefile",
  "example/rails3/app/controllers/application_controller.rb",
  "example/rails3/app/views/application/helper.html.erb",
  "example/rails3/config.ru",
  "example/rails3/config/application.rb",
  "example/rails3/config/boot.rb",
  "example/rails3/config/environment.rb",
  "example/rails3/config/environments/development.rb",
  "example/rails3/config/environments/production.rb",
  "example/rails3/config/environments/test.rb",
  "example/rails3/config/initializers/secret_token.rb",
  "example/rails3/config/initializers/session_store.rb",
  "example/rails3/config/rest-core.yaml",
  "example/rails3/config/routes.rb",
  "example/rails3/test/functional/application_controller_test.rb",
  "example/rails3/test/test_helper.rb",
  "example/rails3/test/unit/rails_util_test.rb",
  "example/rainbows.rb",
  "example/sinatra/config.ru",
  "lib/rest-core/client/bing.rb",
  "lib/rest-core/client/bing/rails_util.rb",
  "lib/rest-core/client/dropbox.rb",
  "lib/rest-core/client/facebook.rb",
  "lib/rest-core/client/facebook/rails_util.rb",
  "lib/rest-core/client/flurry.rb",
  "lib/rest-core/client/flurry/rails_util.rb",
  "lib/rest-core/client/github.rb",
  "lib/rest-core/client/github/rails_util.rb",
  "lib/rest-core/client/linkedin.rb",
  "lib/rest-core/client/linkedin/rails_util.rb",
  "lib/rest-core/client/mixi.rb",
  "lib/rest-core/client/mixi/rails_util.rb",
  "lib/rest-core/client/twitter.rb",
  "lib/rest-core/client/twitter/rails_util.rb",
  "lib/rest-core/util/config.rb",
  "lib/rest-core/util/rails_util_util.rb",
  "lib/rest-more.rb",
  "lib/rest-more/test.rb",
  "lib/rest-more/version.rb",
  "lib/rib/app/rest-core.rb",
  "rest-more.gemspec",
  "task/.gitignore",
  "task/gemgem.rb",
  "test/bing/test_api.rb",
  "test/dropbox/test_api.rb",
  "test/facebook/config/rest-core.yaml",
  "test/facebook/test_api.rb",
  "test/facebook/test_cache.rb",
  "test/facebook/test_default.rb",
  "test/facebook/test_error.rb",
  "test/facebook/test_handler.rb",
  "test/facebook/test_load_config.rb",
  "test/facebook/test_misc.rb",
  "test/facebook/test_oauth.rb",
  "test/facebook/test_old.rb",
  "test/facebook/test_page.rb",
  "test/facebook/test_parse.rb",
  "test/facebook/test_serialize.rb",
  "test/facebook/test_timeout.rb",
  "test/flurry/test_metrics.rb",
  "test/mixi/test_api.rb",
  "test/twitter/test_api.rb"]
  s.homepage = "https://github.com/cardinalblue/rest-more"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.16"
  s.summary = "Various REST clients such as Facebook and Twitter built with [rest-core][]"
  s.test_files = [
  "test/bing/test_api.rb",
  "test/dropbox/test_api.rb",
  "test/facebook/test_api.rb",
  "test/facebook/test_cache.rb",
  "test/facebook/test_default.rb",
  "test/facebook/test_error.rb",
  "test/facebook/test_handler.rb",
  "test/facebook/test_load_config.rb",
  "test/facebook/test_misc.rb",
  "test/facebook/test_oauth.rb",
  "test/facebook/test_old.rb",
  "test/facebook/test_page.rb",
  "test/facebook/test_parse.rb",
  "test/facebook/test_serialize.rb",
  "test/facebook/test_timeout.rb",
  "test/flurry/test_metrics.rb",
  "test/mixi/test_api.rb",
  "test/twitter/test_api.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-core>, [">= 0.8.0"])
    else
      s.add_dependency(%q<rest-core>, [">= 0.8.0"])
    end
  else
    s.add_dependency(%q<rest-core>, [">= 0.8.0"])
  end
end
