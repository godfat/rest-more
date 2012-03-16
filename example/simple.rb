
require 'rest-more'

p RestCore::Twitter.new.statuses('_cardinalblue').first # get user tweets
puts
p RestCore::Github.new.get('users/cardinalblue')        # get user info
puts
p RestCore::Facebook.new.get('4') # get user info
