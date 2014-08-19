
require 'rest-core'

# http://instagram.com/developer/
module RestCore
  Instagram = Builder.client(:client_id, :client_secret, :data) do
    use Timeout       , 10

    use DefaultSite   , 'https://api.instagram.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}
    use DefaultQuery  , nil
    use Oauth2Query   , nil

    use CommonLogger  , nil
    use ErrorHandler  , lambda{ |env| RuntimeError.new(env[RESPONSE_BODY])}
    use ErrorDetectorHttp
    use JsonResponse  , true
    use Cache         , nil, 600
  end
end

module RestCore::Instagram::Client
  include RestCore

  def me query={}, opts={}, &cb
    get('v1/users/self', query, opts, &cb)
  end

  def access_token
    data['access_token']
  end

  def access_token= token
    data['access_token'] = token
  end

  def authorize_url query={}, opts={}
    url('oauth/authorize', {:access_token  => false,
                            :response_type => 'code'}.merge(query), opts)
  end

  def authorize! payload={}, opts={}
    p = {:client_id  => client_id, :client_secret => client_secret,
         :grant_type => 'authorization_code'                      }.
         merge(payload)

    self.data = post('oauth/access_token', p, {:access_token => false,
                                               :client_id    => false}, opts)
  end

  private
  def default_data ;                        {}; end
  def default_query; {:client_id => client_id}; end
end

class RestCore::Instagram
  include RestCore::Instagram::Client
end
