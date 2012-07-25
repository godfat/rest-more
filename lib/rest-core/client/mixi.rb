
# http://developer.mixi.co.jp/connect/mixi_graph_api/
module RestCore
  Mixi = RestCore::Builder.client(
    :data, :consumer_key, :consumer_secret, :redirect_uri) do
    use Timeout       , 10

    use DefaultSite   , 'http://api.mixi-platform.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}

    use Oauth2Header  , 'OAuth', nil

    use CommonLogger  , nil
    use Cache         , nil, 600 do
      use ErrorHandler, lambda{ |env|
        RuntimeError.new(env[RESPONSE_BODY]) }
      use ErrorDetectorHttp
      use JsonDecode  , true
    end
  end
end

module RestCore::Mixi::Client
  include RestCore

  def me query={}, opts={}
    get('2/people/@me/@self', query, opts)
  end

  def access_token
    data['access_token'] if data.kind_of?(Hash)
  end

  def access_token= token
    data['access_token'] = token if data.kind_of?(Hash)
  end

  def authorize_url queries={}
    url('https://mixi.jp/connect_authorize.pl',
        {:client_id     => consumer_key,
         :response_type => 'code',
         :scope         => 'r_profile'}.merge(queries))
  end

  def authorize! payload={}, opts={}
    pl = {:client_id     => consumer_key   ,
          :client_secret => consumer_secret,
          :redirect_uri  => redirect_uri   ,
          :grant_type    => 'authorization_code'}.merge(payload)

    self.data = post('https://secure.mixi-platform.com/2/token', pl, {}, opts)
  end

  private
  def default_data
    {}
  end
end

RestCore::Mixi.send(:include, RestCore::Mixi::Client)
require 'rest-core/client/mixi/rails_util' if
  Object.const_defined?(:Rails)
