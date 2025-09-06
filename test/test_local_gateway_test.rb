require 'test_helper'
require 'local_gateway'

class TestLocalGateway < Minitest::Test
  def test_get_returns_content_from_hash
    gateway = LocalGateway.new({"http://example.com" => "ical data"})
    assert_equal "ical data", gateway.get("http://example.com")
  end
end
