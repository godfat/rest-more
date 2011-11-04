
require 'rest-core/util/rails_util_util'

module RestCore::Github::DefaultAttributes
  def default_log_method; Rails.logger.method(:debug); end
  def default_cache     ; Rails.cache                ; end
end

module RestCore::Github::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Github::RailsUtil.init(Rails)
