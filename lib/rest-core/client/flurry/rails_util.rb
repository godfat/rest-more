
require 'rest-core/util/rails_util_util'

module RestCore::Flurry::DefaultAttributes
  def default_log_method; Rails.logger.method(:debug); end
  def default_cache     ; Rails.cache                ; end
end

module RestCore::Flurry::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Flurry::RailsUtil.init(Rails)
