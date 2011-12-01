
require 'rest-more/test'

describe RC::Bing do
  after do
    WebMock.reset!
    RR.verify
  end

  def stub_with body, query={}
    stub_request(:get, 'http://api.bing.net/json.aspx').
      with(:query => {'JsonType' => 'raw', 'Version' => '2.2'}.merge(query)).
      to_return(:body => body)
  end

  should 'get right' do
    stub_with('{"status":"OK"}')
    RC::Bing.new.get('').should.eq({'status' => 'OK'})
  end

  should 'be able to set AppId' do
    RC::Bing.new(:AppId => 'QQ').AppId.should.eq 'QQ'
  end

  should 'use AppId for requests' do
    stub_with('{}', 'AppId' => 'zz')
    RC::Bing.new(:AppId => 'zz').get('').should.eq({})
  end

  should 'raise correct error' do
    stub_with('{"SearchResponse":{"Errors":[{"Code":2003}]}}')
    lambda{RC::Bing.new.get('')}.should.raise(RC::Bing::Error::NoAccess)
  end
end
