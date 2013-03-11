
require 'rest-core'

# http://developer.github.com/v3/
module RestCore
  Github = Builder.client do
    use Timeout       , 10

    use DefaultSite   , 'https://api.github.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}
    use Oauth2Query   , nil

    use CommonLogger  , nil
    use Cache         , nil, 600 do
      use ErrorHandler, lambda{ |env|
        RuntimeError.new(env[RESPONSE_BODY]['message'])}
      use ErrorDetectorHttp
      use JsonResponse, true
    end
  end
end

module RestCore::Github::Client
  include RestCore

  def me query={}, opts={}
    get('user', query, opts)
  end
end

class RestCore::Github
  include RestCore::Github::Client

  autoload :RailsUtil, 'rest-core/client/github/rails_util' if
    Object.const_defined?(:Rails)
end
