
source 'http://rubygems.org'

gem 'rest-core', :path => 'rest-core' if File.exist?('rest-core/Gemfile')

gem 'rake'
gem 'bacon'
gem 'rr'
gem 'webmock'

gem 'json'
gem 'json_pure'

gem 'rack'
gem 'ruby-hmac'

platforms(:ruby) do
  gem 'yajl-ruby'
end

platforms(:jruby) do
  gem 'jruby-openssl'
end

gem 'rails', '2.3.14' if ENV['RESTMORE'] == 'rails2'
gem 'rails', '3.0.9'  if ENV['RESTMORE'] == 'rails3'
