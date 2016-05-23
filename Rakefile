
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

%w[lib rest-builder/lib rest-builder/promise_pool/lib].each do |path|
  $LOAD_PATH.unshift(File.expand_path("#{dir}/rest-core/#{path}"))
end

Gemgem.init(dir) do |s|
  require 'rest-more/version'
  s.name    = 'rest-more'
  s.version = RestMore::VERSION

  %w[rest-core].each{ |g| s.add_runtime_dependency(g, '>=4.0.0') }

  # exclude rest-core
  s.files.reject!{ |f| f.start_with?('rest-core/') }
end

desc 'Run different json test'
task 'test:json' do
  %w[yajl json].each{ |json|
    Rake.sh "#{Gem.ruby} -S rake -r #{json} test"
  }
end

task 'test' do
  SimpleCov.add_filter('rest-core/lib') if ENV['COV'] || ENV['CI']
end
