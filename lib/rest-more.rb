
require 'rest-core'

module RestCore
  autoload :Dropbox  , 'rest-core/client/dropbox'
  autoload :Facebook , 'rest-core/client/facebook'
  autoload :Firebase , 'rest-core/client/firebase'
  autoload :Github   , 'rest-core/client/github'
  autoload :Instagram, 'rest-core/client/instagram'
  autoload :Linkedin , 'rest-core/client/linkedin'
  autoload :Twitter  , 'rest-core/client/twitter'
end
