
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
::Test::Unit::AssertionFailedError = Class.new(RuntimeError)
require 'rr'
require 'webmock'
WebMock.disable_net_connect!

class ActiveSupport::TestCase
  def normalize_query query, amp='&'
    '?' + query[1..-1].split(amp).sort.join(amp)
  end

  def normalize_url url, amp='&'
    url.sub(/\?.+/){ |query| normalize_query(query, amp) }
  end
end
