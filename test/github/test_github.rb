
require 'rest-more/test'

describe RC::Github do
  after do
    WebMock.reset!
  end

  # TODO: Pork::Failure: Expect [0].==([0, 1, 2]) to return true
  # https://travis-ci.org/godfat/rest-more/jobs/105298582
  would 'get all' do
    link = '</users/godfat/repos?type=o&per_page=100&page=3>; rel="last"'
    headers = {'Link' => link}
    stub_request(:get,
      'https://api.github.com/users/godfat/repos?type=o&per_page=100').
      to_return(:body => [0], :headers => headers).times(2)
    stub_request(:get,
      'https://api.github.com/users/godfat/repos?type=o&per_page=100&page=2').
      to_return(:body => [1], :headers => headers).times(2)
    stub_request(:get,
      'https://api.github.com/users/godfat/repos?type=o&per_page=100&page=3').
      to_return(:body => [2], :headers => headers).times(2)

    args = ['users/godfat/repos', {:type => 'o'}]
    exps = [0, 1, 2]
    g = RC::Github.new
    g.all(*args) do |res|
      res.should.eq exps
      g.all(*args).should.eq exps
    end
    g.wait
  end
end
