
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-core/lib"))

Gemgem.init(dir) do |s|
  require 'rest-more/version'
  s.name     = 'rest-more'
  s.version  = RestMore::VERSION
  s.homepage = 'https://github.com/godfat/rest-more'

  %w[rest-core].each{ |g| s.add_runtime_dependency(g, '>=3.2.0') }

  # exclude rest-core
  s.files.reject!{ |f| f.start_with?('rest-core/') }
end

module Gemgem
  module_function
  def test_rails *rails
    rails.each{ |framework|
      opts = Rake.application.options
      args = (opts.singleton_methods - [:rakelib, :trace_output]).map{ |arg|
               if arg.to_s !~ /=$/ && opts.send(arg)
                 "--#{arg}"
               else
                 ''
               end
             }.join(' ')
      Rake.sh "cd example/#{framework}; #{Gem.ruby} -S rake test #{args}"
    }
  end
end

desc 'Run example tests'
task 'test:example' do
  Gemgem.test_rails('rails3')
end

desc 'Run all tests'
task 'test:all' => ['test', 'test:example']

desc 'Run different json test'
task 'test:json' do
  %w[yajl json].each{ |json|
    Rake.sh "#{Gem.ruby} -S rake -r #{json} test"
  }
end

task 'test:travis' do
  case ENV['RESTMORE']
  when 'rails3'; Gemgem.test_rails('rails3')
  else         ; Rake::Task['test'].invoke
  end
end
