
require 'test_helper'
require 'rr'

class RailsUtilTest < ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  def setup_mock url
    @controller = Class.new do
      def self.helper      dummy   ; end
      def self.rescue_from dummy, _; end
      include RestCore::Facebook::RailsUtil
    end.new
    mock(@controller).rc_facebook_in_canvas?{ false }
    mock(@controller).request{
      mock(Object.new).url{ url }
    }
  end

  def test_rest_graph_normalized_request_uri_0
    setup_mock(  'http://test.com/?code=123&lang=en')
    assert_equal('http://test.com/?lang=en',
      @controller.send(:rc_facebook_normalized_request_uri))
  end

  def test_rest_graph_normalized_request_uri_1
    setup_mock(  'http://test.com/?lang=en&code=123')
    assert_equal('http://test.com/?lang=en',
      @controller.send(:rc_facebook_normalized_request_uri))
  end

  def test_rest_graph_normalized_request_uri_2
    setup_mock(  'http://test.com/?session=abc&lang=en&code=123')
    assert_equal('http://test.com/?lang=en',
      @controller.send(:rc_facebook_normalized_request_uri))
  end

  def test_rest_graph_normalized_request_uri_3
    setup_mock(  'http://test.com/?code=123')
    assert_equal('http://test.com/',
      @controller.send(:rc_facebook_normalized_request_uri))
  end

  def test_rest_graph_normalized_request_uri_4
    setup_mock(  'http://test.com/?signed_request=abc&code=123')
    assert_equal('http://test.com/',
      @controller.send(:rc_facebook_normalized_request_uri))
  end
end
