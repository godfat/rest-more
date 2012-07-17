
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'be serialized with lighten' do
    engines = begin
                require 'psych'
                YAML::ENGINE.yamler = 'psych' # TODO: probably a bug?
                [Psych, YAML, Marshal]
              rescue LoadError
                [YAML, Marshal]
              end

    engines.each{ |engine|
      test = lambda{ |obj| engine.load(engine.dump(obj)) }
        rg = RC::Facebook.new(:log_handler => lambda{})
      lambda{ test[rg] }.should.raise(Exception)
      test[rg.lighten].should.eq rg.lighten
      lambda{ test[rg] }.should.raise(Exception)
      rg.lighten!
      test[rg.lighten].should.eq rg
    }
  end

  should 'lighten takes options to change attributes' do
    RC::Facebook.new.lighten(:timeout => 100    ).timeout.should.eq 100
    RC::Facebook.new.lighten(:lang    => 'zh-TW').lang.should.eq 'zh-TW'
  end
end
