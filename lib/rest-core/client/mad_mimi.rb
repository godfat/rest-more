require 'rest-core'
require 'crack/xml'

RestCore::MadMimi = RestCore::Builder.client(:data, :username, :api_key,
                                             :promotion_name) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 300
  use s::DefaultSite   , 'https://api.madmimi.com'
  use s::DefaultQuery  , {}
  use s::Cache         , {}, 60
  use s::Defaults      , :data => {}
end

class RestCore::MadMimi::Error < RestCore::Error
end

require 'rest-core/client/mad_mimi/audience_list'

module RestCore::MadMimi::Client
  include RestCore

  POSSIBLE_STATUSES = %w[ignorant sending failed sent received clicked_through
                         bounced retried retry_failed forwarded opted_out
                         abused]

  # https://madmimi.com/developer/mailer/transactional
  #
  # Usage:
  #
  #   client.mailer('ayaya@example.com',
  #                 :subject => 'Subject',
  #                 :raw_html => 'the mail body [[tracking_beacon]]')
  #
  # The transaction code is convert to integer
  def mailer(recipient, options = {})
    options = {:recipients => recipient}.merge(options)
    response = post('/mailer', options)
    if response =~ /^\d+$/
      # response was a string that included RestClient::AbstractResponse,
      # and it overrided #to_i method (which returns status code)
      String.new(response).to_i
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  # https://madmimi.com/developer/mailer/send-to-a-list
  #
  # Usage:
  #
  #   client.mailer_to_list('list_name',
  #                         :subject => 'Subject',
  #                         :raw_html => 'the mail body [[tracking_beacon]]')
  #
  # The transaction code is convert to integer

  def mailer_to_list(list, options = {})
    list = list.join(',') if list.is_a?(Array)
    options = {:list_name => list}.merge(options)
    response = post('/mailer/to_list', options)
    if response =~ /^\d+$/
      # response was a string that included RestClient::AbstractResponse,
      # and it overrided #to_i method (which returns status code)
      String.new(response).to_i
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  # https://madmimi.com/developer/mailer/status
  #
  # Usage:
  #
  #   id = client.mailer(...)
  #   client.status(id)
  #
  # The status is convert to symbol
  def status(id)
    response = get("/mailers/status/#{id.to_i}")
    if POSSIBLE_STATUSES.include?(response)
      response.to_sym
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  # https://madmimi.com/developer/lists
  # Audience lists apis

  def audience_lists
    response = get('/audience_lists/lists.xml')
    Crack::XML.parse(response)['lists']['list'].map do |list|
      RestCore::MadMimi::AudienceList.new(self, list)
    end
  end

  def create_audience_list(name)
    response = post('/audience_lists', :name => name)
    if response.code == 200
      cache.clear
      audience_lists.find { |list| list.name == name }
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  def rename_audience_list(name, new_name)
    response = post("/audience_lists/#{CGI.escape(name)}/rename",
                    :name => new_name)
    if response.code == 200
      cache.clear
      audience_lists.find { |list| list.name == new_name }
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  def destroy_audience_list(name)
    response = post("/audience_lists/#{CGI.escape(name)}", :_method => 'delete')
    if response.code == 200
      cache.clear
    else
      raise RestCore::MadMimi::Error, response
    end
  end

  def query
    {'username' => username,
     'api_key' => api_key,
     'promotion_name' => promotion_name}
  end
end

RestCore::MadMimi.send(:include, RestCore::MadMimi::Client)
