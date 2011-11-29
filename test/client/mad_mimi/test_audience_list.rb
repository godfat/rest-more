require 'rest-more/test'

describe RestCore::MadMimi::AudienceList do
  before do
    @client = mock!
    @list = RestCore::MadMimi::AudienceList.new(@client, :name => 'rc-test')
  end

  should 'destroy the list' do
    mock(@client).destroy_audience_list('rc-test') { :delegated }
    @list.destroy.should.eq(:delegated)
  end

  should 'rename the list' do
    mock(@client).rename_audience_list('rc-test', 'renamed') { true }
    @list.name = 'renamed'
    @list.name.should.eq('renamed')
  end
end
