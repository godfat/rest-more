
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

  should 'receive timeout error in the block' do
    port = 35795
    path = "http://localhost:#{port}/"

    EM.run{
      EM.start_server '127.0.0.1', port, Module.new{
        def receive_data data; end
      }
      RC::Facebook.new(:timeout => 0.00001).get(path){ |e|
        e.first.should.kind_of ::Timeout::Error; EM.stop }}
  end
end
