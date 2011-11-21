
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

  def rc_twitter_setup options={}
    super

    rc_twitter_check_handler
    rc_twitter_check_session
    rc_twitter_check_cookies
    rc_twitter_check_oauth_verifier

    if rc_options_get(RestCore::Twitter, :ensure_authorized) &&
       !rc_twitter.authorized?

      rc_twitter_authorize('ensure authorized')
      false # action halt, redirect to do authorize,
            # eagerly, as opposed to auto_authorize
    else
      true  # keep going
    end
  end

  def rc_twitter_on_unauthorized error=nil
    rc_twitter_authorize(error, false)
  end

  def rc_twitter_authorize error=nil, force_redirect=true
    logger.warn("WARN: Twitter: #{error.inspect}")

    if force_redirect || rc_options_get(RestCore::Twitter, :auto_authorize)
      rc_twitter_cleanup

      callback = rc_twitter_normalized_request_uri
      redirect_url = rc_twitter.authorize_url!(:oauth_callback => callback)
      rc_twitter.oauth_callback = callback
      rc_twitter_write_data_json

      logger.debug(
        "DEBUG: Twitter: redirect to #{redirect_url} from #{callback}")

      redirect_to redirect_url
    end
  end

  # ==================== begin check ================================
  def rc_twitter_storage_key
    "rc_twitter_#{rc_twitter.consumer_key}"
  end

  def rc_twitter_check_oauth_verifier
    return if !rc_twitter.callback || !params[:oauth_verifier]

    rc_twitter.authorize!(:oauth_verifier => params[:oauth_verifier])
    rc_twitter.data.delete('callback')

    logger.debug(
      "DEBUG: Twitter: detected oauth_verifier with #{request.url}," \
      " parsed: #{rc_twitter.data.inspect}")

    rc_twitter_write_data_json if rc_twitter.authorized?
  end

  def rc_twitter_check_handler handler=
      rc_options_get(RestCore::Twitter, :check_handler)

    return if rc_twitter.authorized? || !handler
    rc_twitter.data_json = handler.call
    logger.debug("DEBUG: Twitter: called check_handler, parsed:" \
                 " #{rc_twitter.data.inspect}")
  end

  def rc_twitter_check_session
    return if rc_twitter.authorized?                             ||
              !rc_options_get(RestCore::Twitter, :write_session) ||
              !(data_json = session[rc_twitter_storage_key])

    rc_twitter.data_json = data_json
    logger.debug("DEBUG: Twitter: detected rc_twitter session, parsed:" \
                 " #{rc_twitter.data.inspect}")
  end

  def rc_twitter_check_cookies
    return if rc_twitter.authorized?                             ||
              !rc_options_get(RestCore::Twitter, :write_cookies) ||
              !(data_json = cookies[rc_twitter_storage_key])

    rc_twitter.data_json = data_json
    logger.debug("DEBUG: Twitter: detected rc_twitter cookies, parsed:" \
                 " #{rc_twitter.data.inspect}")
  end
  # ====================   end check ================================
  # ==================== begin write ================================
  def rc_twitter_write_data_json
    rc_twitter_write_handler
    rc_twitter_write_session
    rc_twitter_write_cookies
  end

  def rc_twitter_write_handler handler=
    rc_options_get(RestCore::Twitter, :write_handler)

    return if !handler
    handler.call(data_json = rc_twitter.data_json)
    logger.debug("DEBUG: Twitter: write_handler: data_json => #{data_json}")
  end

  def rc_twitter_write_session
    return if !rc_options_get(RestCore::Twitter, :write_session)
    session[rc_twitter_storage_key] = data_json = rc_twitter.data_json
    logger.debug("DEBUG: Twitter: wrote session: data_json => #{data_json}")
  end

  def rc_twitter_write_cookies
    return if !rc_options_get(RestCore::Twitter, :write_cookies)
    cookies[rc_twitter_storage_key] = data_json = rc_twitter.data_json
    logger.debug("DEBUG: Twitter: wrote cookies: data_json => #{data_json}")
  end
  # ==================== end write ================================



  # ==================== begin misc ================================
  def rc_twitter_cleanup
    session.delete(rc_twitter_storage_key)
    cookies.delete(rc_twitter_storage_key)
  end

  def rc_twitter_normalized_request_uri
    URI.parse(request.url).tap{ |uri|
      uri.query = uri.query.split('&').reject{ |q|
                    q =~ /^(oauth_verifier|oauth_token)\=/
                  }.join('&') if uri.query
      uri.query = nil if uri.query.blank?
    }.to_s
  end
  # ==================== end misc ================================
end

RestCore::Twitter::RailsUtil.init(Rails)
