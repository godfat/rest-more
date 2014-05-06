
require 'rest-more/test'

describe RC::Firebase do
  before do
    stub(Time).now{ Time.at(0) }
  end

  after do
    WebMock.reset!
    Muack.verify
  end

  path = 'https://a.json?auth=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9%0A.eyJ2IjowLCJpYXQiOjAsImQiOm51bGx9%0A.C9JtzZhiCrsClNdAQcE7Irngr2BZJCH4x1p-IHxfrAo%3D%0A'

  def firebase
    RC::Firebase.new(:secret => 'nnf')
  end

  should 'get true' do
    stub_request(:get, path).to_return(:body => 'true')
    firebase.get('https://a').should.eq true
  end

  should 'put {"status":"ok"}' do
    json = '{"status":"ok"}'
    rbon = {'status' => 'ok'}
    stub_request(:put, path).with(:body => json).to_return(:body => json)
    firebase.put('https://a', rbon).should.eq rbon
  end

  should 'parse event source' do
    stub_request(:get, path).to_return(:body => <<-SSE)
event: put
data: {}

event: keep-alive
data: null

event: invalid
data: invalid
SSE
    m = [{'event' => 'put'       , 'data' => {}},
         {'event' => 'keep-alive', 'data' => nil}]
    es = firebase.event_source('https://a')
    es.should.kind_of RC::Firebase::Client::EventSource
    es.onmessage do |event|
      event.should.eq m.shift
    end.onerror do |error|
      error.should.kind_of RC::Json::ParseError
    end.start.wait
    m.should.empty
  end

  check = lambda do |status, klass|
    stub_request(:delete, path).to_return(
      :body => '{}', :status => status)

    lambda{ firebase.delete('https://a').tap{} }.should.raise(klass)

    WebMock.reset!
  end

  should 'raise exception when encountering error' do
    [400, 401, 402, 403, 404, 406, 417].each do |status|
      check[status, RC::Firebase::Error]
    end
    [500, 502, 503].each do |status|
      check[status, RC::Firebase::Error::ServerError]
    end
  end
end
