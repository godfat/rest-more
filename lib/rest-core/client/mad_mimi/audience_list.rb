class RestCore::MadMimi::AudienceList
  attr_reader :client
  attr_reader :id, :name, :display_name, :subscriber_count

  def initialize(client, values = {})
    @client = client
    values.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def mailer(options = {})
    @client.mailer_to_list(@name, options)
  end

  def name=(new_name)
    if client.rename_audience_list(name, new_name)
      @name = new_name
    end
  end

  def destroy
    client.destroy_audience_list(self.name)
  end

  def to_s
    %w"#<RestCore::MadMimi::AudienceList
      @id=%s @name=%s @display_name=%s @subscriber_count=%s>".
      join(' ') % [id, name, display_name, subscriber_count].map(&:inspect)
  end
end
