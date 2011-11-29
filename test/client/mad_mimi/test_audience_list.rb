require 'rest-more/test'

describe RestCore::MadMimi::AudienceList do
  before do
    @client = mock!
    @list = RestCore::MadMimi::AudienceList.new(@client, :name => 'rc-test')
  end

  should 'mailer to list' do
    mock(@client).mailer_to_list('rc-test', :stubbed => :options) { :delegated }
    @list.mailer(:stubbed => :options).should.eq(:delegated)
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
