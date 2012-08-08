
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'get the next/prev page' do
    rg = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      rg.send(kind, {})              .should.eq nil
      rg.send(kind, {'paging' => []}).should.eq nil
      rg.send(kind, {'paging' => {}}).should.eq nil

      stub_request(:get, 'zzz').to_return(:body => '["ok"]')
      rg.send(kind, {'paging' => {type => 'zzz'}}).should.eq ['ok']
    }
  end

  should 'merge all pages into one' do
    rg = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      rg.for_pages(data, -1, {}, kind).should == nil
      rg.for_pages(data,  0, {}, kind).should == nil
      rg.for_pages(data,  1, {}, kind).should == data

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        rg.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z y]})

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        rg.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z]})
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      rg.for_pages(data, 3, {}, kind).should.eq({'data' => %w[z y x]})
    }
  end

  should 'for_pages with callback' do
    rg = RC::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      # invalid pages or just the page itself
      rg.for_pages(data, -1, {}, kind){ |r| r.should.eq  nil }.should.eq rg
      rg.for_pages(data,  0, {}, kind){ |r| r.should.eq  nil }.should.eq rg
      a = []
      rg.for_pages(data,  1, {}, kind){ |r| a << r           }.should.eq rg
      a.should.eq [data, nil]

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        expects = [data, {'data' => %w[y]}, nil]
        rg.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }.should.eq rg
        expects.should.empty?

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        expects = [data, {'data' => 'y'}, nil]
        rg.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }.should.eq rg
        expects.should.empty?
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      expects = [data, {'data' => %w[y], 'paging' => {type => 'yyy'}},
                       {'data' => %w[x]}, nil]
      rg.for_pages(data, 3, {}, kind){ |r|
        r.should.eq expects.shift
      }.should.eq rg
    }
  end
end
