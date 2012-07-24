
require 'rest-more'
require 'eventmachine'

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

puts "RC::Auto for EventMachine"
EM.run{ aget_facebook(:timeout => 0.01){ EM.stop } }
EM.run{ aget_facebook(:timeout => 10.0){ EM.stop } }
EM.run{ Fiber.new{ get_facebook(:timeout => 0.01); EM.stop }.resume }
EM.run{ Fiber.new{ get_facebook(:timeout => 10.0); EM.stop }.resume }
puts
puts "RC::Auto for RestClient"
get_facebook(:timeout => 0.01)
get_facebook(:timeout => 10.0)
