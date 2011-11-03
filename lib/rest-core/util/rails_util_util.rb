
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
  end

  def self.extend_rails_util rails_util, name
    mod = Module.new
    mod.module_eval(<<-RUBY, __FILE__, __LINE__)
    def init app=Rails
      RestCore::Config.
        load_for_rails(RestCore::#{name}, '#{name.downcase}', app)
    end

    def included controller
      # skip if included already, any better way to detect this?
      return if controller.respond_to?(:rc_#{name.downcase}, true)

      controller.helper(RestCore::#{name}::RailsUtil::Helper)
      controller.instance_methods.select{ |method|
        method.to_s =~ /^rc_#{name.downcase}/
      }.each{ |method| controller.send(:protected, method) }
    end
    RUBY
    rails_util.send(:extend, mod)
  end

  def self.include_rails_util rails_util, name
    helper = if rails_util.const_defined?(:Helper)
               rails_util.const_get(:Helper)
             else
               Module.new
             end
    helper.module_eval(<<-RUBY, __FILE__, __LINE__)
      def rc_#{name.downcase}
        controller.send(:rc_#{name.downcase})
      end
    RUBY
    rails_util.const_set(:Helper, helper)
  end

  module_function
  def extract_options members, options, method
    # Hash[] is for ruby 1.8.7
    # map(&:to_sym) is for ruby 1.8.7
    Hash[options.send(method){ |(k, v)| members.map(&:to_sym).member?(k) }]
  end
end

ActiveSupport::Cache::Store.send(:include, RestCore::RailsUtilUtil::Cache)
