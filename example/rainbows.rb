
worker_processes 4 # assuming four CPU cores
preload_app      true

Rainbows! do
  use :EventMachine, :em_client_class => lambda{
    RainbowsEventMachineFiberClient
  }
  worker_connections        100

  client_max_body_size      20*1024*1024 # 20 megabytes
  client_header_buffer_size  8*1024      #  8 kilobytes
end

require 'rest-core'
::RC::Builder.default_app = ::RC::Auto

class RainbowsEventMachineFiberClient < Rainbows::EventMachine::Client
  def app_call input
    Fiber.new{ super }.resume
  end
end

# monkey patch eventmachine to ignore errors and report them,
# instead of crashing!!
module ::EventMachine
  class << self
    alias_method :crashing_stop, :stop
  end

  def self.stop
    if @wrapped_exception
      $stderr.puts("WARN: #{@wrapped_exception.inspect}: " \
                   "#{@wrapped_exception.backtrace.inspect}")
      @wrapped_exception = nil
    else
      crashing_stop
    end
  end
end
