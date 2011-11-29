
require 'rest-more/test'

describe RC::MadMimi, 'mailer api' do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'be able to set promotion_name' do
    client = RC::MadMimi.new(:username => 'me',
                             :api_key => 'key',
                             :promotion_name => 'QQ')
    client.username.should.eq 'me'
    client.api_key.should.eq 'key'
    client.promotion_name.should.eq 'QQ'
  end

  describe 'POST mailer' do
    describe 'when success' do
      should 'returns transaction code' do
        stub_request(:post, 'https://api.madmimi.com/mailer').
          to_return(:body => '15498')

        RC::MadMimi.new.mailer('anyone').should.eq(15498)
      end
    end

    describe 'when failure' do
      should 'raise an error' do
        stub_request(:post, 'https://api.madmimi.com/mailer').
          to_return(:status => 400)

        lambda {
          RC::MadMimi.new.mailer('anyone')
        }.should.raise(RestCore::MadMimi::Error)
      end
    end
  end

  describe 'POST mailer/to_list' do
    describe 'when success' do
      should 'returns transaction code' do
        stub_request(:post, 'https://api.madmimi.com/mailer/to_list').
          with(:body => {"list_name"=>"anyone"}).
          to_return(:body => '15498')

        RC::MadMimi.new.mailer_to_list('anyone').should.eq(15498)

        stub_request(:post, 'https://api.madmimi.com/mailer/to_list').
          with(:body => {"list_name"=>"1st,2nd,3rd"}).
          to_return(:body => '15498')

        RC::MadMimi.new.mailer_to_list(['1st', '2nd', '3rd']).should.eq(15498)
      end
    end

    describe 'when failure' do
      should 'raise an error' do
        stub_request(:post, 'https://api.madmimi.com/mailer/to_list').
          to_return(:status => 400)

        lambda {
          RC::MadMimi.new.mailer_to_list('anyone')
        }.should.raise(RestCore::MadMimi::Error)
      end
    end
  end

  describe 'GET mailers/status' do
    describe 'when status is in possible list' do
      should 'return the status that converted to symbol' do
        RestCore::MadMimi::Client::POSSIBLE_STATUSES.each do |status|
          stub_request(:get, 'https://api.madmimi.com/mailers/status/15498').
            to_return(:body => status)
          RC::MadMimi.new.status('15498').should.eq(status.to_sym)
        end
      end
    end

    describe 'when status is not in possible list' do
      should 'raise an error' do
        stub_request(:get, 'https://api.madmimi.com/mailers/status/15498').
          to_return(:status => 400)
        lambda {
          RC::MadMimi.new.status('15498')
        }.should.raise(RestCore::MadMimi::Error)
      end
    end
  end
end
