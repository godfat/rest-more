
require 'rest-more'

facebook = RC::Facebook.new(:log_method => method(:puts))
puts "rest-client with threads doing concurrent requests"
a = [facebook.get('4'), facebook.get('5')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"

puts "callback also works"
facebook.get('6'){ |r|
  p r['name']
}
puts "It's not blocking... but doing concurrent requests underneath"
facebook.wait # we block here to wait for the request done
puts "DONE"
