require 'rest-more/test'
require 'rest-core/client/instagram'

describe RC::Instagram do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'retrieve user profile based on username' do
    stub_request(:get, %r{https://api.instagram.com/v1/users/search*}).
      to_return(body: <<-JSON)
        {"meta":{"code":200}, "data":[{"username":"restmore", "bio":"", "website":"", "profile_picture":"http://images.ak.instagram.com/profiles/profile_123_75sq_1384489147.jpg", "full_name":"Rest More", "id":"123"}]}
    JSON

    RC::Instagram.new.user_search('restmore').should.eq({
      "meta" => {
        "code" => 200},
      "data" => [{
          "username" => "restmore",
          "bio" => "",
          "website" => "",
          "profile_picture" => "http://images.ak.instagram.com/profiles/profile_123_75sq_1384489147.jpg",
          "full_name" => "Rest More",
          "id" => "123"}] })
  end
end
