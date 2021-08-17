
require 'rest-core'
require 'rest-core/util/hmac'

# https://developers.facebook.com/docs/reference/api
# https://developers.facebook.com/tools/explorer
module RestCore
  Facebook = Builder.client(:app_id, :secret, :data, :old_site) do
    use Timeout       , 10

    use DefaultSite   , 'https://graph.facebook.com/'
    use DefaultHeaders, {'Accept'          => 'application/json',
                         'Accept-Language' => 'en-us'}
    use Oauth2Query   , nil

    use CommonLogger  , nil
    use ErrorHandler  , lambda{ |env| Facebook::Error.call(env) }
    use ErrorDetector , lambda{ |env|
      env[RESPONSE_BODY].kind_of?(Hash) &&
      (env[RESPONSE_BODY]['error'] || env[RESPONSE_BODY]['error_code'])}

    use JsonResponse  , true
    use Cache         , nil, 600

    use Defaults      , :old_site => 'https://api.facebook.com/'
  end
end

class RestCore::Facebook::Error < RestCore::Error
  include RestCore
  class AccessToken        < Facebook::Error; end
  class InvalidAccessToken < AccessToken     ; end
  class MissingAccessToken < AccessToken     ; end

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], env[REQUEST_URI]
    return new(error, url) unless error.kind_of?(Hash)
    if    invalid_token?(error)
      InvalidAccessToken.new(error, url)
    elsif missing_token?(error)
      MissingAccessToken.new(error, url)
    else
      new(error, url)
    end
  end

  def self.invalid_token? error
    (%w[OAuthInvalidTokenException
        OAuthException].include?((error['error'] || {})['type'])) ||
    (error['error_code'] == 190) # Invalid OAuth 2.0 Access Token
  end

  def self.missing_token? error
    (error['error'] || {})['message'] =~ /^An active access token/ ||
    (error['error_code'] == 104) # Requires valid signature
  end
end

module RestCore::Facebook::Client
  include RestCore

  def me query={}, opts={}
    get('me', query, opts)
  end

  def access_token
    data['access_token'] || data['oauth_token'] if data.kind_of?(Hash)
  end

  def access_token= token
    data['access_token'] = token if data.kind_of?(Hash)
  end

  def secret_access_token; "#{app_id}|#{secret}"           ; end
  def accept             ; headers['Accept']               ; end
  def accept=         val; headers['Accept']          = val; end
  def lang               ; headers['Accept-Language']      ; end
  def lang=           val; headers['Accept-Language'] = val; end

  def authorized?        ; !!access_token                  ; end

  def next_page hash, opts={}, &cb
    if hash.nil?
      nil
    elsif hash['paging'].kind_of?(Hash) && hash['paging']['next']
      get(hash['paging']['next'], {}, opts, &cb)
    elsif block_given?
      yield(nil)
      self
    else
      nil
    end
  end

  def prev_page hash, opts={}, &cb
    if hash.nil?
      nil
    elsif hash['paging'].kind_of?(Hash) && hash['paging']['previous']
      get(hash['paging']['previous'], {}, opts, &cb)
    elsif block_given?
      yield(nil)
      self
    else
      nil
    end
  end
  alias_method :previous_page, :prev_page

  def for_pages hash, pages=1, opts={}, kind=:next_page, &cb
    if hash.nil?
      nil
    elsif pages <= 0
      if block_given?
        yield(nil)
        self
      else
        nil
      end
    elsif pages == 1
      if block_given?
        yield(hash)
        yield(nil)
        self
      else
        hash
      end
    else
      if block_given?
        yield(hash)
        send(kind, hash, opts){ |result|
          if result.nil?
            yield(nil)
          else
            for_pages(result, pages - 1, opts, kind, &cb)
          end
        }
      else
        merge_data(
          for_pages(send(kind, hash, opts), pages - 1, opts, kind),
          hash)
      end
    end
  end

  # cookies, app_id, secrect related below

  def parse_rack_env! env
    env['HTTP_COOKIE'].to_s =~ /fbs_#{app_id}=([^\;]+)/
    self.data = parse_fbs!($1)
  end

  def parse_cookies! cookies
    self.data = if   fbsr = cookies["fbsr_#{app_id}"]
                  parse_fbsr!(fbsr)
                else fbs  = cookies["fbs_#{app_id}"]
                  parse_fbs!(fbs)
                end
  end

  def parse_fbs! fbs
    self.data = check_sig_and_return_data(
      # take out facebook sometimes there but sometimes not quotes in cookies
      ParseQuery.parse_query(fbs.to_s.sub(/^"/, '').sub(/"$/, '')))
  end

  def parse_fbsr! fbsr
    old_data = parse_signed_request!(fbsr)
    # beware! maybe facebook would take out the code someday
    return self.data = old_data unless old_data && old_data['code']
    # passing empty redirect_uri is needed!
    arg = {:code => old_data['code'], :redirect_uri => ''}

    if block_given?
      authorize!(arg){ |r| self.data = old_data.merge(r) }
    else
      self.data = old_data.merge(authorize!(arg))
    end
  end

  def parse_json! json
    self.data = json &&
      check_sig_and_return_data(Json.decode(json))
  rescue Json::ParseError
    self.data = nil
  end

  def fbs
    "#{fbs_without_sig(data).join('&')}&sig=#{calculate_sig(data)}"
  end

  # facebook's new signed_request...

  def parse_signed_request! request
    sig_encoded, json_encoded = request.split('.')
    return self.data = nil unless sig_encoded && json_encoded
    sig,  json = [sig_encoded, json_encoded].map{ |str|
      "#{str.tr('-_', '+/')}==".unpack('m').first
    }
    self.data = check_sig_and_return_data(
                  Json.decode(json).merge('sig' => sig)){
                    Hmac.sha256(secret, json_encoded)
                  }
  rescue Json::ParseError
    self.data = nil
  end

  # oauth related

  def authorize_url query={}, opts={}
    url('dialog/oauth',
        {:client_id => app_id, :access_token => nil}.merge(query),
        {:site => 'https://www.facebook.com/'}.merge(opts))
  end

  def authorize! payload={}, opts={}
    p = {:client_id => app_id, :client_secret => secret}.merge(payload)
    args = ['oauth/access_token', p, {},
            {:json_response => false}.merge(opts)]

    if block_given?
      post(*args){ |r| yield(self.data = ParseQuery.parse_query(r)) }
    else
      self.data = ParseQuery.parse_query(post(*args))
    end
  end

  # old rest facebook api, i will definitely love to remove them someday

  def old_rest path, query={}, opts={}, &cb
    get("method/#{path}", {:format => 'json'}.merge(query),
      {:site => old_site}.merge(opts), &cb)
  end

  def secret_old_rest path, query={}, opts={}, &cb
    old_rest(path, query, {:secret => true}.merge(opts), &cb)
  end

  def fql code, query={}, opts={}, &cb
    old_rest('fql.query', {:query => code}.merge(query), opts, &cb)
  end

  def fql_multi codes, query={}, opts={}, &cb
    old_rest('fql.multiquery',
      {:queries => Json.encode(codes)}.merge(query), opts, &cb)
  end

  def exchange_sessions query={}, opts={}, &cb
    q = {:client_id => app_id, :client_secret => secret,
         :type => 'client_cred'}.merge(query)
    post(url('oauth/exchange_sessions', q),
         {}, {}, opts, &cb)
  end

  private
  def default_data
    {}
  end

  def build_env env={}
    super(env.inject({}){ |r, (k, v)|
      case k.to_s
        when 'secret'     ; r['access_token'] = secret_access_token
        else              ; r[k.to_s]         = v
      end
      r
    })
  end

  def check_sig_and_return_data cookies
    cookies if secret && if block_given?
                           yield
                         else
                           calculate_sig(cookies)
                         end == cookies['sig']
  end

  def calculate_sig cookies
    Digest::MD5.hexdigest(fbs_without_sig(cookies).join + secret)
  end

  def fbs_without_sig cookies
    cookies.reject{ |(k, _)| k == 'sig' }.sort.map{ |a| a.join('=') }
  end

  def merge_data lhs, rhs
    [lhs, rhs].each{ |hash|
      return rhs.reject{ |k, v| k == 'paging' } if
        !hash.kind_of?(Hash) || !hash['data'].kind_of?(Array)
    }
    lhs['data'].unshift(*rhs['data'])
    lhs
  end
end

class RestCore::Facebook
  include RestCore::Facebook::Client

  autoload :RailsUtil, 'rest-core/client/facebook/rails_util' if
    Object.const_defined?(:Rails)
end
