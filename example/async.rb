
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
  }
end

puts "RC::Coolio"
RC::Facebook.builder.default_app = RC::Coolio
aget_facebook(:timeout => 0.01)
aget_facebook(:timeout => 10.0)
Coolio::Loop.default.run
puts

def get_facebook opts={}
  p RC::Facebook.new(opts).get('4')
  puts "DONE"
rescue Timeout::Error
  puts "TIMEOUT"
end

puts "RC::CoolioFiber"
RC::Facebook.builder.default_app = RC::CoolioFiber
Fiber.new{ get_facebook(:timeout => 0.01) }.resume
Fiber.new{ get_facebook(:timeout => 10.0) }.resume
Coolio::Loop.default.run
puts



puts "RC::EmHttpRequest"
RC::Facebook.builder.default_app = RC::EmHttpRequest
EM.run{ RC::Facebook.new.get('4'){ |r| p r; EM.stop } }
puts



puts "RC::EmHttpRequestFiber"
RC::Facebook.builder.default_app = RC::EmHttpRequestFiber
EM.run{ Fiber.new{ p RC::Facebook.new.get('4'); puts "DONE"; EM.stop }.resume}
