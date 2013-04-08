
require 'rest-core'

# https://dev.twitter.com/docs
module RestCore
  Twitter = Builder.client do
    use Timeout       , 10

    use DefaultSite   , 'https://api.twitter.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}

    use Oauth1Header  ,
      'oauth/request_token', 'oauth/access_token', 'oauth/authorize'

    use CommonLogger  , nil
    use Cache         , nil, 600 do
      use ErrorHandler, lambda{ |env| Twitter::Error.call(env) }
      use ErrorDetectorHttp
      use JsonResponse, true
    end
  end
end

# https://dev.twitter.com/docs/error-codes-responses
class RestCore::Twitter::Error < RestCore::Error
  include RestCore
  class ServerError         < Twitter::Error; end

  class BadRequest          < Twitter::Error; end
  class Unauthorized        < Twitter::Error; end
  class Forbidden           < Twitter::Error; end
  class NotFound            < Twitter::Error; end
  class NotAcceptable       < Twitter::Error; end
  class EnhanceYourCalm     < Twitter::Error; end

  class InternalServerError < Twitter::Error::ServerError; end
  class BadGateway          < Twitter::Error::ServerError; end
  class ServiceUnavailable  < Twitter::Error::ServerError; end

  attr_reader :error, :code, :url
  def initialize error, code, url=''
    @error, @code, @url = error, code, url
    super("[#{code}] #{error.inspect} from #{url}")
  end

  def self.call env
    error, code, url = env[RESPONSE_BODY], env[RESPONSE_STATUS],
                       Middleware.request_uri(env)
    return new(error, code, url) unless error.kind_of?(Hash)
    case code
      when 400; BadRequest
      when 401; Unauthorized
      when 403; Forbidden
      when 404; NotFound
      when 406; NotAcceptable
      when 420; EnhanceYourCalm
      when 500; InternalServerError
      when 502; BadGateway
      when 503; ServiceUnavailable
      else    ; self
    end.new(error, code, url)
  end
end

module RestCore::Twitter::Client
  include RestCore

  def me query={}, opts={}
    get('1.1/account/verify_credentials.json', query, opts)
  end

  def tweet status, media=nil, payload={}, query={}, opts={}
    if media
      post('1.1/statuses/update_with_media.json',
        {:status => status, 'media[]' => media}.merge(payload),
        query, opts)
    else
      post('1.1/statuses/update.json',
        {:status => status}.merge(payload),
        query, opts)
    end
  end

  def search query, params={}, opts={}
    get('1.1/search/tweets.json', {q: query}.merge(params), opts)
  end

  def statuses user, query={}, opts={}
    get('1.1/statuses/user_timeline.json', {:id => user}.merge(query), opts)
  end
end

class RestCore::Twitter
  include RestCore::ClientOauth1
  include RestCore::Twitter::Client

  autoload :RailsUtil, 'rest-core/client/twitter/rails_util' if
    Object.const_defined?(:Rails)
end
