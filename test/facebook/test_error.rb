
require 'rest-more/test'

describe RC::Facebook::Error do
  after do
    WebMock.reset!
  end

  should 'have the right ancestors' do
    RC::Facebook::Error::AccessToken.should.lt RC::Facebook::Error

    RC::Facebook::Error::InvalidAccessToken.should.lt \
      RC::Facebook::Error::AccessToken

    RC::Facebook::Error::MissingAccessToken.should.lt \
      RC::Facebook::Error::AccessToken
  end

  def error2env hash
    {RC::RESPONSE_BODY => hash,
     RC::REQUEST_PATH  => '/' ,
     RC::REQUEST_QUERY => {}}
  end

  should 'parse right' do
    %w[OAuthInvalidTokenException OAuthException].each{ |type|
      RC::Facebook::Error.call(error2env('error' => {'type' => type})).
        should.kind_of?(RC::Facebook::Error::InvalidAccessToken)
    }

    RC::Facebook::Error.call(
      error2env('error'=>{'type'   =>'QueryParseException',
                          'message'=>'An active access token..'})).
      should.kind_of?(RC::Facebook::Error::MissingAccessToken)

    RC::Facebook::Error.call(
      error2env('error'=>{'type'   =>'QueryParseException',
                          'message'=>'Oh active access token..'})).
      should.not.kind_of?(RC::Facebook::Error::MissingAccessToken)

    RC::Facebook::Error.call(error2env('error_code' => 190)).
      should.kind_of?(RC::Facebook::Error::InvalidAccessToken)

    RC::Facebook::Error.call(error2env('error_code' => 104)).
      should.kind_of?(RC::Facebook::Error::MissingAccessToken)

    RC::Facebook::Error.call(error2env('error_code' => 999)).
      should.not.kind_of?(RC::Facebook::Error::AccessToken)

    error = RC::Facebook::Error.call(error2env(['not a hash']))
    error.should.not.kind_of?(RC::Facebook::Error::AccessToken)
    error.should    .kind_of?(RC::Facebook::Error)
  end

  should 'nuke cache upon errors' do
    stub_request(:get, 'https://graph.facebook.com/me').
      to_return(:body => '{"error":"wrong"}').times(2)

    rg = RC::Facebook.new(:cache => {},
                          :error_handler => lambda{|env|env})
    rg.get('me'); rg.get('me')
    rg.cache.values.should.eq []
  end
end
