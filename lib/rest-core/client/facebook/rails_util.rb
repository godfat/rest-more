
require 'rest-core/util/rails_util_util'

require 'cgi'
require 'uri'

module RestCore::Facebook::DefaultAttributes
  def default_log_method            ; Rails.logger.method(:debug); end
  def default_cache                 ; Rails.cache                ; end
  def default_canvas                ; ''                         ; end
  def default_iframe                ; false                      ; end
  def default_auto_authorize        ; false                      ; end
  def default_auto_authorize_options; {}                         ; end
  def default_auto_authorize_scope  ; ''                         ; end
  def default_ensure_authorized     ; false                      ; end
  def default_write_session         ; false                      ; end
  def default_write_cookies         ; false                      ; end
  def default_write_handler         ;   nil                      ; end
  def default_check_handler         ;   nil                      ; end
end

module RestCore::Facebook::RailsUtil
  include RestCore::RailsUtilUtil

  def self.included controller
    # skip if included already, any better way to detect this?
    return if controller.respond_to?(:rc_facebook, true)
    super
    controller.rescue_from(RestCore::Facebook::Error::AccessToken,
                           :with => :rc_facebook_on_access_token_error)
  end

  def rc_facebook_setup options={}
    super

    rc_facebook_check_params_signed_request # canvas
    rc_facebook_check_params_session        # i think it would be deprecated
    rc_facebook_check_cookie                # for js sdk (canvas or not)
    rc_facebook_check_code                  # oauth api

    # there are above 4 ways to check the user identity!
    # if nor of them passed, then we can suppose the user
    # didn't authorize for us, but we can check if user has authorized
    # before, in that case, the fbs would be inside session,
    # as we just saved it there

    rc_facebook_check_fbs # check rc_facebook storage

    if rc_options_get(RestCore::Facebook, :ensure_authorized) &&
       !rc_facebook.authorized?

      rc_facebook_authorize('ensure authorized')
      false # action halt, redirect to do authorize,
            # eagerly, as opposed to auto_authorize
    else
      true  # keep going
    end
  end

  def rc_facebook_on_access_token_error error=nil
    rc_facebook_authorize(error, false)
  end

  def rc_facebook_authorize error=nil, force_redirect=true
    logger.warn("WARN: Facebook: #{error.inspect}")

    if force_redirect || rc_facebook_auto_authorize?
      rc_facebook_cleanup

      @rc_facebook_authorize_url = rc_facebook.authorize_url(
        {:redirect_uri => rc_facebook_normalized_request_uri,
         :scope        =>
           rc_options_get(RestCore::Facebook, :auto_authorize_scope)}.
        merge(rc_options_get(RestCore::Facebook, :auto_authorize_options)))

      logger.debug(
        "DEBUG: Facebook: redirect to #{@rc_facebook_authorize_url}")

      rc_facebook_authorize_redirect
    end
  end

  # override this if you want the simple redirect_to
  def rc_facebook_authorize_redirect
    unless rc_facebook_in_canvas?
      redirect_to @rc_facebook_authorize_url
    else
      rc_facebook_js_redirect(@rc_facebook_authorize_url,
                               rc_facebook_authorize_body)
    end
  end

  def rc_facebook_js_redirect redirect_url, body=''
    render :inline => <<-HTML
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
      <head>
      <script type="text/javascript">
        window.top.location.href = '#{redirect_url}'
      </script>
      <noscript>
        <meta http-equiv="refresh" content="0;url=#{
          CGI.escapeHTML(redirect_url)}"/>
        <meta http-equiv="window-target" content="_top"/>
      </noscript>
      </head>
      <body>
        #{body}
      </bodt>
    </html>
    HTML
  end

  def rc_facebook_authorize_body redirect_url=@rc_facebook_authorize_url
    <<-HTML
    <div>
      Please
      <a href="#{CGI.escapeHTML(redirect_url)}" target="_top">authorize</a>
      if this page is not automatically redirected.
    </div>
    HTML
  end



  # ==================== begin facebook check ======================
  def rc_facebook_check_params_signed_request
    return if rc_facebook.authorized? || !params[:signed_request]

    rc_facebook.parse_signed_request!(params[:signed_request])
    logger.debug("DEBUG: Facebook: detected signed_request,"  \
                 " parsed: #{rc_facebook.data.inspect}")

    if rc_facebook.authorized?
      rc_facebook_write_fbs
    else
      logger.warn(
        "WARN: Facebook: bad signed_request: #{params[:signed_request]}")
    end
  end

  # if the code is bad or not existed,
  # check if there's one in session,
  # meanwhile, there the sig and access_token is correct,
  # that means we're in the context of canvas
  def rc_facebook_check_params_session
    return if rc_facebook.authorized? || !params[:session]

    rc_facebook.parse_json!(params[:session])
    logger.debug("DEBUG: Facebook: detected session, parsed:" \
                 " #{rc_facebook.data.inspect}")

    if rc_facebook.authorized?
      rc_facebook_write_fbs
    else
      logger.warn("WARN: Facebook: bad session: #{params[:session]}")
    end
  end

  # if we're not in canvas nor code passed,
  # we could check out cookies as well.
  def rc_facebook_check_cookie
    return if rc_facebook.authorized?                 ||
              (!cookies["fbsr_#{rc_facebook.app_id}"] &&
               !cookies["fbs_#{rc_facebook.app_id}"])

    rc_facebook.parse_cookies!(cookies)
    logger.debug("DEBUG: Facebook: detected cookies, parsed:" \
                 " #{rc_facebook.data.inspect}")
  end

  # exchange the code with access_token
  def rc_facebook_check_code
    return if rc_facebook.authorized? || !params[:code]

    rc_facebook.authorize!(
      :code         => params[:code],
      :redirect_uri => rc_facebook_normalized_request_uri)

    logger.debug(
      "DEBUG: Facebook: detected code with "   \
      "#{rc_facebook_normalized_request_uri}," \
      " parsed: #{rc_facebook.data.inspect}")

    rc_facebook_write_fbs if rc_facebook.authorized?
  end
  # ==================== end facebook check ======================



  # ==================== begin check ================================
  def rc_facebook_storage_key
    "rc_facebook_#{rc_facebook.app_id}"
  end

  def rc_facebook_check_fbs
    rc_facebook_check_handler # custom method to store fbs
    rc_facebook_check_session # prefered way to store fbs
    rc_facebook_check_cookies # in canvas, session might not work..
  end

  def rc_facebook_check_handler handler=
      rc_options_get(RestCore::Facebook, :check_handler)

    return if rc_facebook.authorized? || !handler
    rc_facebook.parse_fbs!(handler.call)
    logger.debug("DEBUG: Facebook: called check_handler, parsed:" \
                 " #{rc_facebook.data.inspect}")
  end

  def rc_facebook_check_session
    return if rc_facebook.authorized?                             ||
              !rc_options_get(RestCore::Facebook, :write_session) ||
              !(fbs = session[rc_facebook_storage_key])

    rc_facebook.parse_fbs!(fbs)
    logger.debug("DEBUG: Facebook: detected rc_facebook session, parsed:" \
                 " #{rc_facebook.data.inspect}")
  end

  def rc_facebook_check_cookies
    return if rc_facebook.authorized?                             ||
              !rc_options_get(RestCore::Facebook, :write_cookies) ||
              !(fbs = cookies[rc_facebook_storage_key])

    rc_facebook.parse_fbs!(fbs)
    logger.debug("DEBUG: Facebook: detected rc_facebook cookies, parsed:" \
                 " #{rc_facebook.data.inspect}")
  end
  # ====================   end check ================================
  # ==================== begin write ================================
  def rc_facebook_write_fbs
    rc_facebook_write_handler
    rc_facebook_write_session
    rc_facebook_write_cookies
  end

  def rc_facebook_write_handler handler=
    rc_options_get(RestCore::Facebook, :write_handler)

    return if !handler
    handler.call(fbs = rc_facebook.fbs)
    logger.debug("DEBUG: Facebook: called write_handler: fbs => #{fbs}")
  end

  def rc_facebook_write_session
    return if !rc_options_get(RestCore::Facebook, :write_session)
    session[rc_facebook_storage_key] = fbs = rc_facebook.fbs
    logger.debug("DEBUG: Facebook: wrote session: fbs => #{fbs}")
  end

  def rc_facebook_write_cookies
    return if !rc_options_get(RestCore::Facebook, :write_cookies)
    cookies[rc_facebook_storage_key] = fbs = rc_facebook.fbs
    logger.debug("DEBUG: Facebook: wrote cookies: fbs => #{fbs}")
  end
  # ==================== end write ================================



  # ==================== begin misc ================================
  def rc_facebook_cleanup
    cookies.delete("fbs_#{rc_facebook.app_id}")
    cookies.delete("fbsr_#{rc_facebook.app_id}")
    cookies.delete(rc_facebook_storage_key)
    session.delete(rc_facebook_storage_key)
  end

  def rc_facebook_normalized_request_uri
    uri = if rc_facebook_in_canvas?
            # rails 3 uses newer rack which has fullpath
            "http://apps.facebook.com/#{
              rc_options_get(RestCore::Facebook, :canvas)}" +
            (request.respond_to?(:fullpath) ?
              request.fullpath : request.request_uri)
          else
            request.url
          end

    rc_facebook_filter_uri(uri)
  end

  def rc_facebook_filter_uri uri
    URI.parse(uri).tap{ |uri|
      uri.query = uri.query.split('&').reject{ |q|
                    q =~ /^(code|session|signed_request)\=/
                  }.join('&') if uri.query
      uri.query = nil if uri.query.blank?
    }.to_s
  rescue URI::InvalidURIError => e
    if @rc_facebook_filter_uri_retry
      raise e
    else
      @rc_facebook_filter_uri_retry = uri = URI.encode(uri)
      retry
    end
  end

  def rc_facebook_in_canvas?
    !rc_options_get(RestCore::Facebook, :canvas).blank?
  end

  def rc_facebook_auto_authorize?
    client = RestCore::Facebook
    !rc_options_get(client, :auto_authorize_scope)  .blank? ||
    !rc_options_get(client, :auto_authorize_options).blank? ||
     rc_options_get(client, :auto_authorize)
  end
  # ==================== end misc ================================
end

RestCore::Facebook::RailsUtil.init(Rails)
