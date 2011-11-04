
require 'rest-core/util/rails_util_util'

module RestCore::Linkedin::DefaultAttributes
  def default_log_method; Rails.logger.method(:debug); end
  def default_cache     ; Rails.cache                ; end
end

module RestCore::Linkedin::RailsUtil
  include RestCore::RailsUtilUtil
end

RestCore::Linkedin::RailsUtil.init(Rails)
