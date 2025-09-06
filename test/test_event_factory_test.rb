require 'test_helper'
require 'event'
require 'unfetchable_event'

class TestEventFactory < Minitest::Test
  def test_concatenates_icals
    event1 = Event.new("ical1", "url1")
    event2 = Event.new("ical2", "url2")
    combined_event = Event.from_events([event1, event2])
    assert_equal "ical1\nical2", combined_event.ical
  end

  def test_filters_out_unfetchable_events
    event1 = Event.new("ical1", "url1")
    unfetchable_event = UnfetchableEvent.new
    event2 = Event.new("ical2", "url2")
    combined_event = Event.from_events([event1, unfetchable_event, event2])
    assert_equal "ical1\nical2", combined_event.ical
  end
end
