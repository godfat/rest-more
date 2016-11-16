
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__, :submodules =>
  %w[rest-core
     rest-core/rest-builder
     rest-core/rest-builder/promise_pool]) do |s|
  require 'rest-more/version'
  s.name    = 'rest-more'
  s.version = RestMore::VERSION

  s.add_runtime_dependency('rest-core', '>=4.0.0')
end

desc 'Run different json test'
task 'test:json' do
  %w[yajl json].each{ |json|
    Rake.sh "#{Gem.ruby} -S rake -r #{json} test"
  }
end
