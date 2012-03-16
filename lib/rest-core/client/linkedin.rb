
require 'rest-core'

# http://developer.linkedin.com/documents/linkedin-api-resource-map
RestCore::Linkedin = RestCore::Builder.client do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.linkedin.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::DefaultQuery  , {'format' => 'json'}

  use s::Oauth1Header  ,
    'uas/oauth/requestToken', 'uas/oauth/accessToken',
    'https://www.linkedin.com/uas/oauth/authorize'

  use s::CommonLogger  , nil
  use s::Cache         , nil, 600 do
    use s::ErrorHandler, lambda{ |env|
      if env[s::ASYNC]
        if env[s::RESPONSE_BODY].kind_of?(::Exception)
          env
        else
          env.merge(s::RESPONSE_BODY =>
                      RuntimeError.new(env[s::RESPONSE_BODY]['message']))
        end
      else
        raise env[s::RESPONSE_BODY]['message']
      end}
    use s::ErrorDetectorHttp
    use s::JsonDecode  , true
  end
end

module RestCore::Linkedin::Client
  include RestCore

  def me query={}, opts={}
    get('v1/people/~', query, opts)
  end

  def authorize_url
    url(authorize_path, :oauth_token => oauth_token, :format => false)
  end
end

RestCore::Linkedin.send(:include, RestCore::ClientOauth1)
RestCore::Linkedin.send(:include, RestCore::Linkedin::Client)
require 'rest-core/client/linkedin/rails_util' if
  Object.const_defined?(:Rails)
