
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    Muack.verify
  end

  should 'respect timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{}')
    any_instance_of(RC::Timeout::TimerThread){ |timer|
      mock(timer).on_timeout.proxy
    }
    RC::Facebook.new.get('me').should.eq({})
  end

  should 'override timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => 'true')
    mock(RC::Timeout::TimerThread).new(99, is_a(Timeout::Error)).proxy
    RC::Facebook.new(:timeout => 1).get('me', {}, :timeout => 99).
      should.eq true
  end
end
