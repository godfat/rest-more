
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
  end

  would 'return true in authorized? if there is an access_token' do
    RC::Facebook.new(:access_token => '1').authorized?.should.eq true
    RC::Facebook.new(:access_token => nil).authorized?.should.eq false
  end

  would 'treat oauth_token as access_token as well' do
    rg = RC::Facebook.new
    hate_facebook = 'why the hell two different name?'
    rg.data['oauth_token'] = hate_facebook
    rg.authorized?.should.eq true
    rg.access_token.should.eq hate_facebook
  end

  would 'build correct headers' do
    rg = RC::Facebook.new(:accept => 'text/html',
                          :lang   => 'zh-tw')

    rg.dry.call(rg.send(:build_env)){ |res|
      headers = res[RC::REQUEST_HEADERS]
      headers['Accept'         ].should.eq 'text/html'
      headers['Accept-Language'].should.eq 'zh-tw'
    }
  end

  would 'create access_token in query string' do
    rg = RC::Facebook.new(:access_token => 'token')
    rg.dry.call(rg.send(:build_env)){ |res|
      res[RC::REQUEST_QUERY].should.eq({'access_token' => 'token'})
    }
  end

  would 'build correct query string' do
    rg = RC::Facebook.new(:access_token => 'token')
    rg.url('', :message => 'hi!!').
      should.eq "#{rg.site}?access_token=token&message=hi%21%21"

    rg.access_token = nil
    rg.url('', :message => 'hi!!', :subject => '(&oh&)').
      should.eq "#{rg.site}?message=hi%21%21&subject=%28%26oh%26%29"
  end

  would 'auto decode json' do
    rg = RC::Facebook.new(:json_response => true)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should.eq []
  end

  would 'not auto decode json' do
    rg = RC::Facebook.new(:json_response => false)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should.eq '[]'
  end

  would 'give attributes' do
    RC::Facebook.new(:json_response => false).attributes.
      keys.map(&:to_s).sort.should.eq \
      RC::Facebook.members.map(&:to_s).sort
  end
end
