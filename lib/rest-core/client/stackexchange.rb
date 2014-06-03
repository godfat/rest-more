
require 'rest-core'

# http://api.stackexchange.com/docs
module RestCore
  StackExchange = Builder.client(:client_id, :client_secret, :key, :data) do
    use Timeout       , 10

    use DefaultSite   , 'https://api.stackexchange.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}
    use DefaultQuery  , nil
    use Oauth2Query   , nil

    use CommonLogger  , nil
    use Cache         , nil, 600 do
      use ErrorHandler, lambda{ |env|
        RuntimeError.new(env[RESPONSE_BODY]['error_message'])}
      use ErrorDetectorHttp
      use JsonResponse, true
    end
  end
end

module RestCore::StackExchange::Client
  include RestCore

  def me query={}, opts={}
    get('me', query, opts)
  end

  def access_token
    data['access_token']
  end

  def access_token= token
    data['access_token'] = token
  end

  def authorize_url query={}, opts={}
    url('https://stackexchange.com/oauth',
      {:access_token => false, :key => false, :site => false,
       :client_id => client_id}.merge(query), opts)
  end

  def authorize! payload={}, opts={}
    p = {:client_id  => client_id, :client_secret => client_secret}.
        merge(payload)

    self.data = ParseQuery.parse_query(
      post('https://stackexchange.com/oauth/access_token', p,
           {:access_token => false, :key => false, :site => false},
           {:json_response => false}.merge(opts)))
  end

  private
  def default_data ;                                      {}; end
  def default_query; {:key => key, :site => 'stackoverflow'}; end
end

class RestCore::StackExchange
  include RestCore::StackExchange::Client
end
