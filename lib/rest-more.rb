
require 'rest-core'

module RestCore
  autoload :Config  , 'rest-core/util/config'

  autoload :Github  , 'rest-core/client/github'
  autoload :Twitter , 'rest-core/client/twitter'
  autoload :Linkedin, 'rest-core/client/linkedin'
  autoload :Facebook, 'rest-core/client/facebook'
  autoload :Mixi    , 'rest-core/client/mixi'
  autoload :Flurry  , 'rest-core/client/flurry'
end
