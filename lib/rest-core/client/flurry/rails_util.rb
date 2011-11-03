
require 'rest-core/util/rails_util_util'

module RestCore::Flurry::DefaultAttributes
  def default_log_method ; Rails.logger.method(:debug); end
  def default_cache      ; Rails.cache                ; end
  def default_api_key    ; nil                        ; end
  def default_access_code; nil                        ; end
end

module RestCore::Flurry::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Flurry::RailsUtil.init(Rails)
