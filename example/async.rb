
require 'rest-more'

# RC::Builder.default_app = # for global default_app setting

def aget_facebook opts={}
  RC::Facebook.new(opts).get('4'){ |response|
    if response.kind_of?(::Timeout::Error)
      puts "TIMEOUT"
    else
      p response
      puts "DONE"
    end
    yield if block_given?
  }
end

def get_facebook opts={}
  p RC::Facebook.new(opts).get('4')
  puts "DONE"
rescue Timeout::Error
  puts "TIMEOUT"
end

puts "RC::Coolio"
RC::Facebook.builder.default_app = RC::Coolio
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



puts "RC::EmHttpRequest"
RC::Facebook.builder.default_app = RC::EmHttpRequest
EM.run{ aget_facebook(:timeout => 0.01){ EM.stop } }
EM.run{ aget_facebook(:timeout => 10.0){ EM.stop } }
puts



puts "RC::EmHttpRequestFiber"
RC::Facebook.builder.default_app = RC::EmHttpRequestFiber
EM.run{ Fiber.new{ get_facebook(:timeout => 0.01); EM.stop }.resume }
EM.run{ Fiber.new{ get_facebook(:timeout => 10.0); EM.stop }.resume }
