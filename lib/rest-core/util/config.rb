
require 'erb'
require 'yaml'

module RestCore; end
module RestCore::Config
  extend self

  DefaultModuleName = 'DefaultAttributes'

  def load_for_rails klass, namespace=nil, app=Rails
    default_attributes_module(klass) # make sure the default is there
                                     # even if there's no config file
    root = File.expand_path(app.root)
    path = ["#{root}/config/rest-core.yaml", # YAML should use .yaml
            "#{root}/config/rest-core.yml" ].find{|p| File.exist?(p)}
    return if path.nil?
    RestCore::Config.load(klass, path, app.env, namespace)
  end

  def load klass, path, env, namespace=nil
    config   = YAML.load(ERB.new(File.read(path)).result(binding))
    defaults = config[env]
    return false unless defaults
    return false unless defaults[namespace] if namespace
    data = if namespace
             defaults[namespace]
           else
             defaults
           end
    raise ArgumentError.new("#{data} is not a hash") unless
      data.kind_of?(Hash)

    default_attributes_module(klass).module_eval(
      data.inject(["extend self\n"]){ |r, (k, v)|
        # quote strings, leave others free (e.g. false, numbers, etc)
        r << <<-RUBY
          def default_#{k}
            #{v.inspect}
          end
        RUBY
      }.join, __FILE__, __LINE__)
  end

  def default_attributes_module klass
    mod = if klass.const_defined?(DefaultModuleName)
            klass.const_get(DefaultModuleName)
          else
            klass.send(:const_set, DefaultModuleName, Module.new)
          end

    singleton_class = if klass.respond_to?(:singleton_class)
                        klass.singleton_class
                      else
                        class << klass; self; end
                      end

    klass.send(:extend, mod) unless singleton_class < mod
    mod
  end
end
