
require 'rest-core'

RestCore::Bing = RestCore::Builder.client(:AppId) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 10

  use s::DefaultSite   , 'http://api.bing.net/json.aspx'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::DefaultQuery  , {}

  use s::CommonLogger  , nil
  use s::Cache         , nil, 600 do
    use s::ErrorHandler,  lambda{ |env|
                            raise ::RestCore::Bing::Error.call(env) }
    use s::ErrorDetector, lambda{ |env|
      if        env[s::RESPONSE_BODY].kind_of?(Hash) &&
         (res = env[s::RESPONSE_BODY]['SearchResponse']).kind_of?(Hash)
          res['Errors']
      end}
    use s::JsonDecode  , true
  end
end

module RestCore::Bing::Client
  def query
    {'AppId'    => self.AppId,
     'JsonType' => 'raw'     ,
     'Version'  => '2.2'     }
  end

  def search_image term, query={}, opts={}
    get('', {:Query => term, :Sources => 'Image'}.merge(query), opts)[
      'SearchResponse']['Image']['Results'] || []
  end

  def search_image_urls term, query={}, opts={}
    search_image(term, query, opts).map{ |i| i['MediaUrl'] }
  end
end

class RestCore::Bing::Error < RestCore::Error
  include RestCore
  class MissingParameter              < Bing::Error; end
  class InvalidParameter              < Bing::Error; end
  class QueryTooLong                  < Bing::Error; end
  class AppIdNotFunctioning           < Bing::Error; end
  class ExceededLimit                 < Bing::Error; end
  class NoAccess                      < Bing::Error; end
  class ResultsTemporarilyUnavailable < Bing::Error; end
  class ServiceTemporarilyUnavailable < Bing::Error; end
  class SourceTypeError               < Bing::Error; end

  attr_reader :error, :url
  def initialize error, url=''
    @error, @url = error, url
    super("#{error.inspect} from #{url}")
  end

  def self.call env
    error, url = env[RESPONSE_BODY], Middleware.request_uri(env)
    code       = extract_error_code(error)

    return new(env[FAIL], url) unless code

    case code
    when 1001; MissingParameter
    when 1002; InvalidParameter
    when 1005; QueryTooLong
    when 2001; AppIdNotFunctioning
    when 2002; ExceededLimit
    when 2003; NoAccess
    when 3001; ResultsTemporarilyUnavailable
    when 3002; ServiceTemporarilyUnavailable
    when 4001; SourceTypeError
    end.new(error, url)
  end

  def self.extract_error_code error
    code    = error.kind_of?(Hash)                     &&
     (error = error['SearchResponse']).kind_of?(Hash)  &&
     (error = error['Errors']        ).kind_of?(Array) &&
     (error = error[0]               ).kind_of?(Hash)  &&
     (error = error['Code']          )

    code && code.to_i
  end
end

RestCore::Bing.send(:include, RestCore::Bing::Client)
require 'rest-core/client/bing/rails_util' if
  Object.const_defined?(:Rails)
