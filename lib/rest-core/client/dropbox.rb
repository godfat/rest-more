
require 'rest-core'

# https://www.dropbox.com/developers/reference/api
RestCore::Dropbox = RestCore::Builder.client(:root) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'https://api.dropbox.com/'
  use s::DefaultHeaders, {'Accept'       => 'application/json',
                          'Content-Type' => 'application/octet-stream'}

  use s::Oauth1Header  ,
    '1/oauth/request_token', '1/oauth/access_token',
    'https://www.dropbox.com/1/oauth/authorize'

  use s::CommonLogger  , nil
  use s::Cache         , nil, 600 do
    use s::ErrorHandler, lambda{ |env|
                           raise ::RestCore::Dropbox::Error.call(env) }
    use s::ErrorDetectorHttp
    use s::JsonDecode  , true
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

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], Middleware.request_uri(env)
    return new(error, url) unless error.kind_of?(Hash)
    case env[RESPONSE_STATUS]
      when 400; BadRequest
      when 401; Unauthorized
      when 403; Forbidden
      when 404; NotFound
      when 405; MethodNotAllowed
      when 503; ServiceUnavailable
      when 507; OverStorageQuota
      else    ; if env[RESPONSE_STATUS] / 100 == 5
                  Dropbox::Error::ServerError
                else
                  Dropbox::Error
                end
    end.new(error, url)
  end
end

module RestCore::Dropbox::Client
  include RestCore

  def me query={}, opts={}
    get('1/account/info', query, opts)
  end

  def default_root
    'sandbox'
  end

  def download path, query={}, opts={}
    get("https://api-content.dropbox.com/1/files/#{root}/#{path}",
        query, {:json_decode => false}.merge(opts))
  end

  def upload path, file, query={}, opts={}
    put("https://api-content.dropbox.com/1/files_put/#{root}/#{path}",
        file, query, opts)
  end

  def ls path='', query={}, opts={}
    get("1/metadata/#{root}/#{path}", query, opts)['contents'].
      map{ |c| c['path'] }
  end
end

RestCore::Dropbox.send(:include, RestCore::ClientOauth1)
RestCore::Dropbox.send(:include, RestCore::Dropbox::Client)
