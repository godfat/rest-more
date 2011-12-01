
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'respect timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{}')
    mock.proxy(Timeout).timeout(numeric)
    RC::Facebook.new.get('me').should.eq({})
  end

  should 'override timeout' do
    mock(Timeout).timeout(99){ {RC::Facebook::RESPONSE_BODY => true} }
    RC::Facebook.new(:timeout => 1).get('me', {}, :timeout => 99).
      should.eq true
  end
end
