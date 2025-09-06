require 'test_helper'
require 'unfetchable_event'

class TestUnfetchableEvent < Minitest::Test
  def test_ical_returns_nil
    event = UnfetchableEvent.new
    assert_nil event.ical
  end

  def test_url_returns_nil
    event = UnfetchableEvent.new
    assert_nil event.url
  end
end
