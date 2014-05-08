
module RestCore; end
module RestCore::RailsUtilUtil
  def self.load_config klass, namespace=nil, app=Rails
    default_attributes_module(klass) # make sure the default is there
                                     # even if there's no config file
    root = File.expand_path(app.root)
    path = ["#{root}/config/rest-core.yaml", # YAML should use .yaml
            "#{root}/config/rest-core.yml" ].find{|p| File.exist?(p)}
    return if path.nil?
    RestCore::Config.load(klass, path, app.env, namespace)
  end

  module Cache
    def []    key       ;  read(key)                ; end
    def []=   key, value; write(key, value)         ; end
    def store key, value,
              options={}; write(key, value, options); end
  end

  module InstanceMethod
    module_function # to mark below private in controllers
    def rc_setup client, options={}
      rc_options_ctl(client).merge!(
        rc_options_extract(client.members, options, :reject))

      rc_options_new(client).merge!(
        rc_options_extract(client.members, options, :select))
    end

    def rc_options_get client, key
      if rc_options_ctl(client).has_key?(key)
        rc_options_ctl(client)[key]
      else
        client.send("default_#{key}")
      end
    end

    def rc_options_ctl client
      @rc_options_ctl              ||= {}
      @rc_options_ctl[client.name] ||= {}
    end

    def rc_options_new client
      @rc_options_new              ||= {}
      @rc_options_new[client.name] ||= {}
    end

    def rc_options_extract members, options, method
      options.send(method){ |(k, v)| members.member?(k) }
    end
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
      RestCore::RailsUtilUtil.load_config(RestCore::#{name}, '#{meth}', app)
    end

    def included controller
      # skip if included already, any better way to detect this?
      return if controller.private_instance_methods.include?(:rc_#{meth})

      controller.send(:include, RestCore::RailsUtilUtil::InstanceMethod)

      controller.helper(RestCore::#{name}::RailsUtil::Helper)
      controller.instance_methods.select{ |method|
        method.to_s =~ /^rc_#{meth}/
      }.each{ |method| controller.send(:private, method) }
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
      @rc_#{meth} ||= client.new(rc_options_new(client))
    end

    def rc_#{meth}_setup options={}
      client = RestCore::#{name}
      rc_setup(client, options)

      # we'll need to reinitialize rc_#{meth} with the new options,
      # otherwise if you're calling rc_#{meth} before rc_#{meth}_setup,
      # you'll end up with default options without the ones you've passed
      # into rc_#{meth}_setup.
      rc_#{meth}.send(:initialize, rc_options_new(client))

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
end

ActiveSupport::Cache::Store.send(:include, RestCore::RailsUtilUtil::Cache)
if ActiveSupport::Cache.const_defined?(:DalliStore)
  ActiveSupport::Cache::DalliStore.
    send(:include, RestCore::RailsUtilUtil::Cache)
end
