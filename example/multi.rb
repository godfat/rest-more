
require 'rest-more'
require 'eventmachine'
RestCore::EmHttpRequest # there might be a autoload bug?
                        # omitting this line would cause
                        # stack level too deep (SystemStackError)

RestCore::Builder.default_app = RestCore::Auto
facebook = RestCore::Facebook.new(:log_method => method(:puts))

EM.run{
  Fiber.new{
    fiber = Fiber.current
    result = {}
    facebook.get('4'){ |response|
      result[0] = response
      fiber.resume(result) if result.size == 2
    }
    puts "It's not blocking..."
    facebook.get('4'){ |response|
      result[1] = response
      fiber.resume(result) if result.size == 2
    }
    p Fiber.yield
    EM.stop
  }.resume
  puts "It's not blocking..."
}
