
require 'rest-more'
require 'eventmachine'

EM.run{
  Fiber.new{
    p RC::Facebook.new.get('4')
    EM.stop
  }.resume
  puts "It's not blocking..."
}
