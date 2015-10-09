
require 'rest-core'

# https://www.dropbox.com/developers/reference/api
module RestCore
  Dropbox = Builder.client(:root) do
    use Timeout       , 10

    use DefaultSite   , 'https://api.dropbox.com/'
    use DefaultHeaders, {'Accept'       => 'application/json',
                         'Content-Type' => 'application/octet-stream'}

    use Oauth1Header  ,
      '1/oauth/request_token', '1/oauth/access_token',
      'https://www.dropbox.com/1/oauth/authorize'

    use CommonLogger  , nil
    use ErrorHandler  , lambda{ |env| Dropbox::Error.call(env) }
    use ErrorDetectorHttp
    use JsonResponse  , true
    use Cache         , nil, 600
  end
end

class RestCore::Dropbox::Error < RestCore::Error
  include RestCore
  class ServerError         < Dropbox::Error; end

  class BadRequest          < Dropbox::Error; end
  class Unauthorized        < Dropbox::Error; end
  class Forbidden           < Dropbox::Error; end
  class NotFound            < Dropbox::Error; end
  class MethodNotAllowed    < Dropbox::Error; end

  # a 5xx error which is not a server error
  class OverStorageQuota    < Dropbox::Error; end

  class ServiceUnavailable  < Dropbox::Error::ServerError; end

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
      when 405; MethodNotAllowed
      when 503; ServiceUnavailable
      when 507; OverStorageQuota
      else    ; if code / 100 == 5
                  Dropbox::Error::ServerError
                else
                  Dropbox::Error
                end
    end.new(error, code, url)
  end
end

module RestCore::Dropbox::Client
  include RestCore

  def me query={}, opts={}, &cb
    get('1/account/info', query, opts, &cb)
  end

  def default_root
    'sandbox'
  end

  def download path, query={}, opts={}, &cb
    get("https://content.dropboxapi.com/1/files/#{root}/#{path}",
        query, {:json_response => false}.merge(opts), &cb)
  end

  def upload path, file, query={}, opts={}, &cb
    put("https://content.dropboxapi.com/1/files_put/#{root}/#{path}",
        file, query, opts, &cb)
  end

  def ls path='', query={}, opts={}
    args = ["1/metadata/#{root}/#{path}", query, opts]
    if block_given?
      get(*args){ |r| yield(r['contents'].map{ |c| c['path'] }) }
    else
      get(*args)['contents'].map{ |c| c['path'] }
    end
  end
end

class RestCore::Dropbox
  include RestCore::ClientOauth1
  include RestCore::Dropbox::Client
end
