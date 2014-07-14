
require 'rest-more/test'

describe RC::Facebook do
  would 'be serialized with lighten' do
    require 'yaml'
    [YAML, Marshal].each{ |engine|
      test = lambda{ |obj| engine.load(engine.dump(obj)) }
        rg = RC::Facebook.new(:error_handler => lambda{})
      lambda{ test[rg] }.should.raise(TypeError)
      test[rg.lighten].should.eq rg.lighten
      lambda{ test[rg] }.should.raise(TypeError)
      rg.lighten!
      test[rg.lighten].should.eq rg
    }
  end

  would 'lighten takes options to change attributes' do
    RC::Facebook.new.lighten(:timeout => 100    ).timeout.should.eq 100
    RC::Facebook.new.lighten(:lang    => 'zh-TW').lang.should.eq 'zh-TW'
  end
end
