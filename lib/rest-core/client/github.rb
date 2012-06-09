
require 'rest-core'

# http://developer.github.com/v3/
RestCore::Github = RestCore::Builder.client do
  s = RestCore
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.github.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::Oauth2Query   , nil

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

module RestCore::Github::Client
  include RestCore

  def me query={}, opts={}
    get('user', query, opts)
  end
end

RestCore::Github.send(:include, RestCore::Github::Client)
require 'rest-core/client/github/rails_util' if
  Object.const_defined?(:Rails)
