
require 'rest-core/util/rails_util_util'

module RestCore::Twitter::DefaultAttributes
  def default_log_method       ; Rails.logger.method(:debug); end
  def default_cache            ; Rails.cache                ; end
  def default_auto_authorize   ; false                      ; end
  def default_ensure_authorized; false                      ; end
  def default_write_session    ; false                      ; end
  def default_write_cookies    ; false                      ; end
  def default_write_handler    ;   nil                      ; end
  def default_check_handler    ;   nil                      ; end
end

module RestCore::Twitter::RailsUtil
  include RestCore::RailsUtilUtil

  def self.included controller
    # skip if included already, any better way to detect this?
    return if controller.respond_to?(:rc_twitter, true)
    super
    controller.rescue_from(RestCore::Twitter::Error::Unauthorized,
                           :with => :rc_twitter_on_unauthorized)
  end

  def rc_twitter_on_access_token_error error=nil
    rc_twitter_authorize(error, false)
  end

  def rc_twitter_authorize error=nil, force_redirect=true
    logger.warn("WARN: Twitter: #{error.inspect}")

    if force_redirect || rc_options_get(RestCore::Twitter, :auto_authorize)
      redirect_url = rc_twitter.authorize_url!

      logger.debug(
        "DEBUG: Twitter: redirect to #{redirect_url}")

      rc_twitter_cleanup
      redirect_to redirect_url
    end
  end

  def rc_twitter_cleanup
    cookies.delete(rc_twitter_storage_key)
    session.delete(rc_twitter_storage_key)
  end
end

RestCore::Twitter::RailsUtil.init(Rails)
