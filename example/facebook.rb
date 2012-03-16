
require 'rest-more'
require 'eventmachine'

RestCore::Builder.default_app = RestCore::EmHttpRequest

EM.run{
  Fiber.new{
    p RestCore::Facebook.new.get('4')
    EM.stop
  }.resume
  puts "It's not blocking..."
}
