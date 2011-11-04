
require 'rest-core/util/rails_util_util'

module RestCore::Twitter::DefaultAttributes
  def default_log_method; Rails.logger.method(:debug); end
  def default_cache     ; Rails.cache                ; end
end

module RestCore::Twitter::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Twitter::RailsUtil.init(Rails)
