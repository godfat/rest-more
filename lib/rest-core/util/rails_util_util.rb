
module RestCore; end
module RestCore::RailsUtilUtil
  module Cache
    def []    key       ;  read(key)                ; end
    def []=   key, value; write(key, value)         ; end
    def store key, value,
              options={}; write(key, value, options); end
  end

  def self.included rails_util, name=rails_util.name[/(\w+)::\w+$/, 1]
     extend_rails_util(rails_util, name)
    include_rails_util(rails_util, name)
          setup_helper(rails_util, name)
  end

  def self.extend_rails_util rails_util, name
    meth = name.downcase
    mod  = if rails_util.const_defined?(:ClassMethod)
             rails_util.const_get(:ClassMethod)
           else
             Module.new
           end
    mod.module_eval(<<-RUBY, __FILE__, __LINE__)
    def init app=Rails
      RestCore::Config.load_for_rails(RestCore::#{name}, '#{meth}', app)
    end

    def included controller
      # skip if included already, any better way to detect this?
      return if controller.respond_to?(:rc_#{meth}, true)

      controller.helper(RestCore::#{name}::RailsUtil::Helper)
      controller.instance_methods.select{ |method|
        method.to_s =~ /^rc_#{meth}/
      }.each{ |method| controller.send(:protected, method) }
    end
    RUBY
    rails_util.send(:extend, mod)
    rails_util.const_set(:ClassMethod, mod)
  end

  def self.include_rails_util rails_util, name
    meth = name.downcase
    mod  = if rails_util.const_defined?(:InstanceMethod)
             rails_util.const_get(:InstanceMethod)
           else
             Module.new
           end
    mod.module_eval(<<-RUBY, __FILE__, __LINE__)
    def rc_#{meth}
      client = RestCore::#{name}
      @rc_#{meth} ||= client.new(RestCore::RailsUtilUtil.options_new(client))
    end

    def setup_#{meth} options={}
      client = RestCore::#{name}
      RailsUtilUtil.setup(client, options)

      # we'll need to reinitialize rc_#{meth} with the new options,
      # otherwise if you're calling rc_#{meth} before rc_#{meth}_setup,
      # you'll end up with default options without the ones you've passed
      # into rc_#{meth}_setup.
      rc_#{meth}.send(:initialize, RailsUtilUtil.options_new(client))

      true # keep going
    end
    RUBY
    rails_util.send(:include, mod)
    rails_util.const_set(:InstanceMethod, mod)
  end

  def self.setup_helper rails_util, name
    meth = name.downcase
    mod  = if rails_util.const_defined?(:Helper)
             rails_util.const_get(:Helper)
           else
             Module.new
           end
    mod.module_eval(<<-RUBY, __FILE__, __LINE__)
    def rc_#{meth}
      controller.send(:rc_#{meth})
    end
    RUBY
    rails_util.const_set(:Helper, mod)
  end



  # -----------------------------------------------------------------------



  def self.setup client, options={}
    options_ctl(client).merge!(
      extract_options(client.members, options, :reject))

    options_new(client).merge!(
      extract_options(client.members, options, :select))
  end

  def self.extract_options members, options, method
    # Hash[] is for ruby 1.8.7
    # map(&:to_sym) is for ruby 1.8.7
    Hash[options.send(method){ |(k, v)| members.map(&:to_sym).member?(k) }]
  end

  def self.options_get client, key
    if options_ctl(client).has_key?(key)
      options_ctl(client)[key]
    else
      client.send("default_#{key}")
    end
  end

  def self.options_ctl client
    @options_ctl              ||= {}
    @options_ctl[client.name] ||= {}
  end

  def self.options_new client
    @options_new              ||= {}
    @options_new[client.name] ||= {}
  end
end

ActiveSupport::Cache::Store.send(:include, RestCore::RailsUtilUtil::Cache)
