require 'test_helper'
require 'local_gateway'

require 'uri'

class TestLocalGateway < Minitest::Test
  def test_get_returns_content_from_hash
    gateway = LocalGateway.new({"http://example.com" => "ical data"})
    assert_equal "ical data", gateway.get("http://example.com")
  end

  def test_post_returns_content_from_hash
    gateway = LocalGateway.new({"POST:http://example.com:#{URI.encode_www_form({ "message" => { "test": 1 } })}" => "data"})
    assert_equal "data", gateway.post("http://example.com", { "message" => { "test":1 } })
  end
end
