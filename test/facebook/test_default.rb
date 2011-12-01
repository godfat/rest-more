
require 'rest-more/test'

describe RC::Facebook do
  should 'honor default attributes' do
    RC::Facebook.members.reject{ |name|
      name.to_s =~ /method$|handler$|detector$/ }.each{ |name|
        RC::Facebook.new.send(name).should ==
        RC::Facebook.new.send("default_#{name}")
    }
  end

  should 'use module to override default attributes' do
    klass = RC::Facebook.dup
    klass.send(:include, Module.new do
      def default_app_id
        '1829'
      end
    end)

    klass.new.app_id.should.eq('1829')
  end
end
