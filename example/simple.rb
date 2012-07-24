
require 'rest-more'

p RC::Twitter.new.statuses('_cardinalblue').first # get user tweets
puts
p RC::Github.new.get('users/cardinalblue')        # get user info
puts
p RC::Facebook.new.get('4') # get user info
