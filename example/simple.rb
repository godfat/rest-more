
require 'rest-more'

p RC::Twitter.new.statuses('godfat').first # get user tweets
puts
p RC::Github.new.get('users/godfat')        # get user info
puts
p RC::Facebook.new.get('4') # get user info
