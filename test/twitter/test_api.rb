
require 'rest-more/test'

describe RC::Twitter do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'get right' do
    stub_request(:get,
      'https://api.twitter.com/1.1/account/verify_credentials.json').
      to_return(:body => '{"status": "OK"}')

    RC::Twitter.new.me.should.eq({'status' => 'OK'})
  end

#  def check status, klass
#    stub_request(:delete, 'https://api.twitter.com/123').to_return(
#      :body => '{}', :status => status)
#
#    lambda{
#      RC::Twitter.new.delete('123').tap{}
#    }.should.raise(klass)
#
#    WebMock.reset!
#  end
#
#  should 'raise exception when encountering error' do
#    [401, 402, 403].each{ |status|
#      check(status, RestCore::Twitter::Error)
#    }
#
#    [500, 502, 503].each{ |status|
#      check(status, RestCore::Twitter::Error::ServerError)
#    }
#  end
end
