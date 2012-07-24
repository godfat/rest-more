
require 'rest-more'
require 'eventmachine'

facebook = RC::Facebook.new(:log_method => method(:puts))

EM.run{
  Fiber.new{
    fiber = Fiber.current
    r0 = facebook.get('4')
    puts "It's not blocking..."
    r1 = facebook.get('4')
    p [r0, r1]
    EM.stop
  }.resume
  puts "It's not blocking..."
}
