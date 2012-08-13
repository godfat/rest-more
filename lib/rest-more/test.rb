
require 'rest-core/test'
require 'rest-more'

module TestHelper
  module_function
  def normalize_query query
    '?' + query[1..-1].split('&').sort.join('&')
  end

  def normalize_url url
    url.sub(/\?.+/){ |query| TestHelper.normalize_query(query) }
  end
end
