
require 'rest-more'

# RC::Builder.default_app = RC::Auto # for global default_app setting

def aget_facebook opts={}
  RC::Facebook.new(opts).get('4'){ |response|
    if response.kind_of?(::Timeout::Error)
      puts "TIMEOUT aget"
    else
      p response
      puts "DONE aget"
    end
    yield if block_given?
  }
end

def get_facebook opts={}
  p RC::Facebook.new(opts).get('4')
  puts "DONE get"
rescue Timeout::Error
  puts "TIMEOUT get"
end



puts "RC::CoolioAsync"
RC::Facebook.builder.default_app = RC::CoolioAsync
aget_facebook(:timeout => 0.01)
aget_facebook(:timeout => 10.0)
Coolio::Loop.default.run
puts



puts "RC::CoolioFiber"
RC::Facebook.builder.default_app = RC::CoolioFiber
Fiber.new{ get_facebook(:timeout => 0.01) }.resume
Fiber.new{ get_facebook(:timeout => 10.0) }.resume
Coolio::Loop.default.run
puts



puts "RC::Coolio"
RC::Facebook.builder.default_app = RC::Coolio
aget_facebook(:timeout => 0.01)
aget_facebook(:timeout => 10.0)
Fiber.new{ get_facebook(:timeout => 0.01) }.resume
Fiber.new{ get_facebook(:timeout => 10.0) }.resume
Coolio::Loop.default.run
puts



puts "RC::EmHttpRequestAsync"
RC::Facebook.builder.default_app = RC::EmHttpRequestAsync
EM.run{ aget_facebook(:timeout => 0.01){ EM.stop } }
EM.run{ aget_facebook(:timeout => 10.0){ EM.stop } }
puts



puts "RC::EmHttpRequestFiber"
RC::Facebook.builder.default_app = RC::EmHttpRequestFiber
EM.run{ Fiber.new{ get_facebook(:timeout => 0.01); EM.stop }.resume }
EM.run{ Fiber.new{ get_facebook(:timeout => 10.0); EM.stop }.resume }
puts



puts "RC::Auto for Coolio"
RC::Facebook.builder.default_app = RC::Auto
Coolio::TimerWatcher.new(1).attach(Coolio::Loop.default).on_timer{detach}
aget_facebook(:timeout => 0.01)
aget_facebook(:timeout => 10.0)
Fiber.new{ get_facebook(:timeout => 0.01) }.resume
Fiber.new{ get_facebook(:timeout => 10.0) }.resume
Coolio::Loop.default.run
puts
puts "RC::Auto for EventMachine"
EM.run{ aget_facebook(:timeout => 0.01){ EM.stop } }
EM.run{ aget_facebook(:timeout => 10.0){ EM.stop } }
EM.run{ Fiber.new{ get_facebook(:timeout => 0.01); EM.stop }.resume }
EM.run{ Fiber.new{ get_facebook(:timeout => 10.0); EM.stop }.resume }
puts
puts "RC::Auto for RestClient"
get_facebook(:timeout => 0.01)
get_facebook(:timeout => 10.0)
