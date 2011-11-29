require 'rest-more/test'

AL = RestCore::MadMimi::AudienceList

describe RC::MadMimi, 'list api' do
  before do
    @client = RestCore::MadMimi.new
  end

  after do
    WebMock.reset!
    RR.verify
  end

  should 'get audience lists' do
    stub_request(:get, 'https://api.madmimi.com/audience_lists/lists.xml').
      to_return(:body => 'stubbed body')
    mock(Crack::XML).parse('stubbed body') {
      {
        'lists' => {
          'list' => [
            {'id' => '1', 'name' => 'first'},
            {'id' => '2', 'name' => 'last'},
          ]
        }
      }
    }
    lists = @client.audience_lists
    lists.size.should.eq(2)
    lists.first.tap do |first|
      first.client.should.eq(@client)
      first.should.be.a.kind_of(AL)
      first.id.should.eq('1')
      first.name.should.eq('first')
    end
    lists.last.tap do |last|
      last.client.should.eq(@client)
      last.should.be.a.kind_of(AL)
      last.id.should.eq('2')
      last.name.should.eq('last')
    end
  end

  should 'create audience list' do
    stub_request(:post, 'https://api.madmimi.com/audience_lists').
      with(:params => {:name => 'rc-test'})
    mock(@client).audience_lists {
      [AL.new(@client, :name => 'first'),
       AL.new(@client, :name => 'rc-test'),
       AL.new(@client, :name => 'last')]
    }
    @client.create_audience_list('rc-test').name.should.eq('rc-test')

    stub_request(:post, 'https://api.madmimi.com/audience_lists').
      to_return(:status => 422)
    lambda {
      @client.create_audience_list('error')
    }.should.raise(RestCore::MadMimi::Error)
  end

  should 'rename audience list' do
    stub_request(:post,
                 'https://api.madmimi.com/audience_lists/rc-test/rename').
      with(:params => {:name => 'renamed'})
    mock(@client).audience_lists {
      [AL.new(@client, :name => 'first'),
       AL.new(@client, :name => 'renamed'),
       AL.new(@client, :name => 'last')]
    }
    list = @client.rename_audience_list('rc-test', 'renamed')
    list.name.should.eq('renamed')

    stub_request(:post, 'https://api.madmimi.com/audience_lists/error/rename').
      with(:params => {:name => 'renamed'}).
      to_return(:status => 422)
    lambda {
      @client.rename_audience_list('error', 'renamed')
    }.should.raise(RestCore::MadMimi::Error)
  end

  should 'destroy audience list' do
    stub_request(:post, 'https://api.madmimi.com/audience_lists/rc-test')
    @client.destroy_audience_list('rc-test')

    stub_request(:post, 'https://api.madmimi.com/audience_lists/error').
      to_return(:status => 422)
    lambda {
      @client.destroy_audience_list('error')
    }.should.raise(RestCore::MadMimi::Error)
  end
end
