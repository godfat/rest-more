
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'respect timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{}')
    any_instance_of(RC::Timeout::TimerThread){ |timer|
      mock.proxy(timer).on_timeout
    }
    RC::Facebook.new.get('me').should.eq({})
  end

  should 'override timeout' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => 'true')
    mock.proxy(RC::Timeout::TimerThread).new(99, is_a(Timeout::Error))
    RC::Facebook.new(:timeout => 1).get('me', {}, :timeout => 99).
      should.eq true
  end
end
