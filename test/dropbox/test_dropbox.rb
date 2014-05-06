
require 'rest-more/test'

describe RC::Dropbox do
  after do
    WebMock.reset!
    Muack.verify
  end

  should 'get right' do
    stub_request(:get, 'https://api.dropbox.com/1/account/info').
      to_return(:body => '{"status": "OK"}')

    RC::Dropbox.new.me.should.eq({'status' => 'OK'})
  end

  def check status, klass
    stub_request(:delete, 'https://api.dropbox.com/123').to_return(
      :body => '{}', :status => status)

    lambda{
      RC::Dropbox.new.delete('123').tap{}
    }.should.raise(klass)

    WebMock.reset!
  end

  should 'raise exception when encountering error' do
    [401, 402, 403].each{ |status| check(status, RC::Dropbox::Error) }
    [500, 502, 503].each{ |status| check(status, RC::Dropbox::Error::
                                                 ServerError)        }
  end
end
