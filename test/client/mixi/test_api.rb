
require 'rest-more/test'

describe RC::Mixi do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'get right' do
    stub_request(:get, 'http://api.mixi-platform.com/me').
      to_return(:body => '{"status": "OK"}')

    RC::Mixi.new.get('me').should.eq({'status' => 'OK'})
  end

  should 'be able to set access_token' do
    RC::Mixi.new(:access_token => 'QQ').access_token.should.eq 'QQ'
  end
end
