
require 'rest-core'

# http://developer.github.com/v3/
module RestCore
  Github = Builder.client(:client_id, :client_secret, :data) do
    use Timeout       , 10

    use DefaultSite   , 'https://api.github.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}
    use Oauth2Query   , nil

    use CommonLogger  , nil
    use ErrorHandler  , lambda{ |env| Github::Error.call(env) }
    use ErrorDetectorHttp
    use JsonResponse  , true
    use Cache         , nil, 600
  end
end

class RestCore::Github::Error < RestCore::Error
  include RestCore
  class ServerError         < Github::Error; end
  class ClientError         < Github::Error; end

  class BadRequest          < Github::Error; end
  class Unauthorized        < Github::Error; end
  class Forbidden           < Github::Error; end
  class NotFound            < Github::Error; end
  class UnprocessableEntity < Github::Error; end
  class InternalServerError < Github::Error::ServerError; end

  attr_reader :error, :code, :url
  def initialize error, code, url=''
    @error, @code, @url = error, code, url
    super("[#{code}] #{error.inspect} from #{url}")
  end

  def self.call env
    error, code, url = env[RESPONSE_BODY], env[RESPONSE_STATUS],
                       env[REQUEST_URI]
    return new(error, code, url) unless error.kind_of?(Hash)
    case code
      when 400; BadRequest
      when 401; Unauthorized
      when 403; Forbidden
      when 404; NotFound
      when 422; UnprocessableEntity
      when 500; InternalServerError
      else    ; self
    end.new(error, code, url)
  end
end

module RestCore::Github::Client
  include RestCore

  MAX_PER_PAGE = 100

  def me query={}, opts={}, &cb
    get('user', query, opts, &cb)
  end

  def access_token
    data['access_token']
  end

  def access_token= token
    data['access_token'] = token
  end

  def authorize_url query={}, opts={}
    url('https://github.com/login/oauth/authorize',
        {:client_id => client_id}.merge(query),
        {:access_token => false}.merge(opts))
  end

  def authorize! payload={}, query={}, opts={}
    p = {:client_id => client_id, :client_secret => client_secret}.
         merge(payload)
    args = ['https://github.com/login/oauth/access_token',
            p, query, {:access_token => false}.merge(opts)]

    if block_given?
      post(*args){ |r| yield(self.data = r) }
    else
      self.data = post(*args)
    end
  end

  def authorized?
    !!access_token
  end

  def all path, query={}, opts={}
    q = {:per_page => MAX_PER_PAGE}.merge(query)
    r = get(path, q, opts.merge(RESPONSE_KEY => PROMISE, ASYNC => true)).
      then{ |response|
        body = response[RESPONSE_BODY] + page_range(response).map{ |page|
          get(path, q.merge(:page => page),
              opts.merge(RESPONSE_KEY => RESPONSE_BODY))
        }.inject([], &:+)
        response.merge(RESPONSE_BODY => body)
      }.future_response

    if block_given?
      yield(r[response_key(opts)])
      self
    else
      r[response_key(opts)]
    end
  end

  private
  def default_data
    {}
  end

  def page_range response
    from = (parse_current_page(response) || 1).to_i + 1
    to   = (parse_last_page(response) || from - 1).to_i
    if from <= to
      from..to
    else
      []
    end
  end

  def parse_current_page response
    RC::ParseQuery.parse_query(URI.parse(response[REQUEST_URI]).query)['page']
  end

  def parse_last_page response
    return unless link = response[RESPONSE_HEADERS]['LINK']
    ls = RC::ParseLink.parse_link(link)
    return unless last_link = ls['last']
    RC::ParseQuery.parse_query(URI.parse(last_link['uri']).query)['page']
  end
end

class RestCore::Github
  include RestCore::Github::Client

  autoload :RailsUtil, 'rest-core/client/github/rails_util' if
    Object.const_defined?(:Rails)
end
