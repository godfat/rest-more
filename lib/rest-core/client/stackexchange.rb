
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
    use ErrorHandler  , lambda{ |env|
      body = env[RESPONSE_BODY]
      # https://api.stackexchange.com/docs/error-handling
      # not sure where to look at the true error message, so search for it
      RuntimeError.new(body['error_message'] ||
                       body['error_description'] ||
                       (body['error'] && body['error']['message']))
    }
    use ErrorDetectorHttp
    use JsonResponse  , true
    use Cache         , nil, 600
  end
end

module RestCore::StackExchange::Client
  include RestCore

  def me query={}, opts={}, &cb
    get('me', query, opts, &cb)
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

  def authorize! payload={}, opts={}, &cb
    p = {:client_id  => client_id, :client_secret => client_secret}.
        merge(payload)

    args = ['https://stackexchange.com/oauth/access_token', p,
            {:access_token => false, :key => false, :site => false},
            opts]

    if block_given?
      post(*args){ |r| yield(self.data = ParseQuery.parse_query(r)) }
    else
      self.data = ParseQuery.parse_query(post(*args))
    end
  end

  def authorized?
    !!access_token
  end

  private
  def default_data ;                                      {}; end
  def default_query; {:key => key, :site => 'stackoverflow'}; end
end

class RestCore::StackExchange
  include RestCore::StackExchange::Client
end
