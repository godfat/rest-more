
require 'rest-core/util/rails_util_util'

module RestCore::Bing::DefaultAttributes
  def default_log_method   ; Rails.logger.method(:debug); end
  def default_cache        ; Rails.cache                ; end
  def default_apiKey       ; nil                        ; end
  def default_apiAccessCode; nil                        ; end
end

module RestCore::Bing::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Bing::RailsUtil.init(Rails)
