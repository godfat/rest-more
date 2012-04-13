
require 'rest-core'

module RestCore
  autoload :Config  , 'rest-core/util/config'

  autoload :Bing    , 'rest-core/client/bing'
  autoload :Dropbox , 'rest-core/client/dropbox'
  autoload :Facebook, 'rest-core/client/facebook'
  autoload :Flurry  , 'rest-core/client/flurry'
  autoload :Github  , 'rest-core/client/github'
  autoload :Linkedin, 'rest-core/client/linkedin'
  autoload :Mixi    , 'rest-core/client/mixi'
  autoload :Twitter , 'rest-core/client/twitter'
end
