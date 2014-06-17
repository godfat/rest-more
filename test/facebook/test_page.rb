
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
  end

  should 'get the next/prev page' do
    f = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      f.send(kind, {})              .should.eq nil
      f.send(kind, {'paging' => []}).should.eq nil
      f.send(kind, {'paging' => {}}).should.eq nil

      stub_request(:get, 'zzz').to_return(:body => '["ok"]')
      f.send(kind, {'paging' => {type => 'zzz'}}).should.eq ['ok']
    }
  end

  should 'merge all pages into one' do
    f = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      f.for_pages(data, -1, {}, kind).should.eq nil
      f.for_pages(data,  0, {}, kind).should.eq nil
      f.for_pages(data,  1, {}, kind).should.eq data

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        f.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z y]})

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        f.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z]})
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      f.for_pages(data, 3, {}, kind).should.eq({'data' => %w[z y x]})
    }
  end

  should 'for_pages with callback' do
    f = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      # invalid pages or just the page itself
      f.for_pages(data, -1, {}, kind){ |r| r.should.eq nil }.should.eq f
      f.for_pages(data,  0, {}, kind){ |r| r.should.eq nil }.should.eq f
      a = []
      f.for_pages(data,  1, {}, kind){ |r| a << r          }.should.eq f
      a.should.eq [data, nil]

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        expects = [data, {'data' => %w[y]}, nil]
        f.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }
        f.wait until expects.empty?

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        expects = [data, {'data' => 'y'}, nil]
        f.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }
        f.wait until expects.empty?
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      expects = [data, {'data' => %w[y], 'paging' => {type => 'yyy'}},
                       {'data' => %w[x]}, nil]
      f.for_pages(data, 3, {}, kind){ |r|
        r.should.eq expects.shift
      }
      f.wait until expects.empty?
    }
  end
end
