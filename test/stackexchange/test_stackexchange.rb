
require 'rest-more/test'

describe RC::StackExchange do
  after do
    WebMock.reset!
  end

  would 'me' do
    stub_request(:get,
      'https://api.stackexchange.com/me?key=yek&site=stackoverflow').
      to_return(:body => '{"name":"meme"}')

    RC::StackExchange.new(:key => 'yek').me.should.eq 'name' => 'meme'
  end
end
