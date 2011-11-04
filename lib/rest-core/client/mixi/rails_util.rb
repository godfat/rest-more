
require 'rest-core/util/rails_util_util'

module RestCore::Mixi::DefaultAttributes
  def default_log_method; Rails.logger.method(:debug); end
  def default_cache     ; Rails.cache                ; end
end

module RestCore::Mixi::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Mixi::RailsUtil.init(Rails)
