
require 'rest-core'

module RestCore
  autoload :Dropbox      , 'rest-core/client/dropbox'
  autoload :Facebook     , 'rest-core/client/facebook'
  autoload :Github       , 'rest-core/client/github'
  autoload :Instagram    , 'rest-core/client/instagram'
  autoload :Linkedin     , 'rest-core/client/linkedin'
  autoload :StackExchange, 'rest-core/client/stackexchange'
  autoload :Twitter      , 'rest-core/client/twitter'
end
