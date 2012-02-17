
require 'rest-more'

# RC::Builder.default_app = # for global default_app setting

puts "RC::Coolio"
RC::Facebook.builder.default_app = RC::Coolio
RC::Facebook.new.get('4'){ |r| p r }
Coolio::Loop.default.run
puts



puts "RC::CoolioFiber"
RC::Facebook.builder.default_app = RC::CoolioFiber
Fiber.new{ p RC::Facebook.new.get('4'); puts "DONE" }.resume
Coolio::Loop.default.run
puts



puts "RC::EmHttpRequest"
RC::Facebook.builder.default_app = RC::EmHttpRequest
EM.run{ RC::Facebook.new.get('4'){ |r| p r; EM.stop } }
puts



puts "RC::EmHttpRequestFiber"
RC::Facebook.builder.default_app = RC::EmHttpRequestFiber
EM.run{ Fiber.new{ p RC::Facebook.new.get('4'); puts "DONE"; EM.stop }.resume}
