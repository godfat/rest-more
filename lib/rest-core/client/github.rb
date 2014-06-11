
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

  MAX_PER_PAGE = 100

  def me query={}, opts={}, &cb
    get('user', query, opts, &cb)
  end

  def all path, query={}, opts={}
    q = {:per_page => MAX_PER_PAGE}.merge(query)
    r = get(path, q, opts.merge(RESPONSE_KEY => PROMISE)).then{ |response|
      body = response[RESPONSE_BODY] + (page_range(response).map{ |page|
        get(path, q.merge(:page => page),
            opts.merge(RESPONSE_KEY => RESPONSE_BODY))
      }.inject(&:+))
      response.merge(RESPONSE_BODY => body)
    }.future_response

    if block_given?
      yield(r[response_key(opts)])
    else
      r[response_key(opts)]
    end
  end

  private
  def page_range response
    from = (parse_current_page(response) || 1).to_i + 1
    to   = (parse_last_page(response) || from).to_i
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
    links = RC::ParseLink.parse_link(response[RESPONSE_HEADERS]['LINK'])
    return unless last_link = links['last']
    RC::ParseQuery.parse_query(URI.parse(last_link['uri']).query)['page']
  end
end

class RestCore::Github
  include RestCore::Github::Client

  autoload :RailsUtil, 'rest-core/client/github/rails_util' if
    Object.const_defined?(:Rails)
end
