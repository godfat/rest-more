
require 'rest-more/test'

describe RC::Facebook do
  after do
    WebMock.reset!
    Muack.verify
  end

  describe 'log method' do
    should 'log whenever doing network request' do
      stub_request(:get, 'https://graph.facebook.com/me').
        to_return(:body => '{}')

      logger = []
      rg = RC::Facebook.new(:log_method => lambda{ |s| logger << [s] })
      rg.get('me').tap{}

      logger.size.should.eq 3 # Auto + Future + Requested
    end
  end

  describe 'with Graph API' do
    before do
      @id    = lambda{ |env| env }
      @error = '{"error":{"type":"Exception","message":"(#2500)"}}'
      @error_hash = RC::Json.decode(@error)

      stub_request(:get, 'https://graph.facebook.com/me').
        to_return(:body => @error)
    end

    should 'call error_handler if error occurred' do
      RC::Facebook.new(:error_handler => @id).get('me').
        should.eq @error_hash
    end

    should 'raise ::RC::Facebook::Error in default error_handler' do
      begin
        RC::Facebook.new.get('me').tap{}
      rescue ::RC::Facebook::Error => e
        e.error  .should.eq @error_hash
        e.message.should.eq \
          "#{@error_hash.inspect} from https://graph.facebook.com/me"
      end
    end
  end

  describe 'with FQL API' do
    # Example of an actual response (without newline)
    # {"error_code":603,"error_msg":"Unknown table: bad_table",
    #  "request_args":[{"key":"method","value":"fql.query"},
    #                  {"key":"format","value":"json"},
    #                  {"key":"query","value":
    #                     "SELECT name FROM bad_table WHERE uid=12345"}]}
    before do
      @id             = lambda{ |env| env }
      @fql_error      = '{"error_code":603,"error_msg":"Unknown table: bad"}'
      @fql_error_hash = RC::Json.decode(@fql_error)

      @bad_fql_query  = 'SELECT name FROM bad_table WHERE uid="12345"'
      bad_fql_request = "https://api.facebook.com/method/fql.query?" \
                        "format=json&query=#{
                          RC::Middleware.escape(@bad_fql_query)}"

      stub_request(:get, bad_fql_request).to_return(:body => @fql_error)
    end

    should 'call error_handler if error occurred' do
      RC::Facebook.new(:error_handler => @id).fql(@bad_fql_query).
        should.eq @fql_error_hash
    end

    should 'raise ::RC::Facebook::Error in default error_handler' do
      begin
        RC::Facebook.new.fql(@bad_fql_query).tap{}
      rescue ::RC::Facebook::Error => e
        e.error  .should.eq @fql_error_hash
        e.message.should.start_with?(
          "#{@fql_error_hash.inspect} from "          \
          "https://api.facebook.com/method/fql.query?")
      end
    end
  end
end
