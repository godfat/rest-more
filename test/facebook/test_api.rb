
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
  end

  would 'generate correct url' do
    RC::Facebook.new(:access_token => 'awesome').
      url('path', :query => 'str').should.eq \
      'https://graph.facebook.com/path?access_token=awesome&query=str'
  end

  would 'request to correct server' do
    stub_request(:get, 'http://nothing.godfat.org/me').with(
      :headers => {'Accept'          => 'text/plain',
                   'Accept-Language' => 'zh-tw',
                   'Accept-Encoding' => /^gzip, ?deflate$/, # this is by ruby
                   'User-Agent'      => 'Ruby'              # this is by ruby
                  }).to_return(:body => '{"data": []}')

    RC::Facebook.new(:site   => 'http://nothing.godfat.org/',
                     :lang   => 'zh-tw',
                     :accept => 'text/plain').
                     get('me').should.eq({'data' => []})
  end

  would 'pass custom headers' do
    stub_request(:get, 'http://example.com/').with(
      :headers => {'Accept'          => 'application/json',
                   'Accept-Language' => 'en-us',
                   'Accept-Encoding' => /^gzip, ?deflate$/, # this is by ruby
                   'User-Agent'      => 'Ruby',             # this is by ruby
                   'X-Forwarded-For' => '127.0.0.1',
                  }).to_return(:body => '{"data": []}')

    RC::Facebook.new.get('http://example.com', {},
      {:headers => {'X-Forwarded-For' => '127.0.0.1'}} ).
      should.eq({'data' => []})
  end

  would 'post right' do
    stub_request(:post, 'https://graph.facebook.com/feed/me').
      with(:body => 'message=hi%20there').to_return(:body => 'ok')

    RC::Facebook.new(:json_response => false).
      post('feed/me', :message => 'hi there').should == 'ok'
  end

  would 'use secret_access_token' do
    stub_request(:get,
      'https://graph.facebook.com/me?access_token=1|2').
      to_return(:body => 'ok')

    rg = RC::Facebook.new(
      :json_response => false, :access_token => 'wrong',
      :app_id => '1', :secret => '2')
    rg.get('me', {}, :secret => true).should.eq 'ok'
    rg.url('me', {}, :secret => true).should.eq \
      'https://graph.facebook.com/me?access_token=1%7C2'
    rg.url('me', {}, :secret => true, :site => '/').should.eq \
      '/me?access_token=1%7C2'
  end

  would 'suppress auto-decode in an api call' do
    stub_request(:get, 'https://graph.facebook.com/woot').
      to_return(:body => 'bad json')

    rg = RC::Facebook.new(:json_response => true)
    rg.get('woot', {}, :json_response => false).should.eq 'bad json'
    rg.json_response.should == true
  end

  would 'not raise exception when encountering error' do
    [500, 401, 402, 403].each{ |status|
      stub_request(:delete, 'https://graph.facebook.com/123').to_return(
        :body => '[]', :status => status)

      RC::Facebook.new.delete('123').should.eq []
    }
  end

  would 'convert query to string' do
    o = Object.new
    def o.to_s; 'i am mock'; end
    stub_request(:get, "https://graph.facebook.com/search?q=i%20am%20mock").
      to_return(:body => 'ok')
    RC::Facebook.new(:json_response => false).
      get('search', :q => o).should.eq 'ok'
  end
end
