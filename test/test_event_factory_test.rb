require 'test_helper'
require 'event'
require 'unfetchable_event'

ICAL_EVENT = <<EOD
BEGIN:VEVENT
UID:66f70a726c06e93e8b4088af@squarespace.com
DTSTAMP:20250902T200007Z
DTSTART:20250905T140000Z
DTEND:20250905T180000Z
SUMMARY:Sharpening Edge Tools - 1 spot left!
GEO:41.916901;-84.028829
LOCATION:Sam Beauford Woodworking Institute\, 1375 N Main St\, Adrian\, MI\
 , 49221\, United States
END:VEVENT
EOD

ICAL_DATA = <<EOD
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Squarespace Inc/Squarespace 6//v6//EN
#{ICAL_EVENT}
END:VCALENDAR
EOD

class TestEventFactory < Minitest::Test
  def test_concatenates_icals
    event1 = Event.new(ICAL_DATA, "url1")
    event2 = Event.new(ICAL_DATA, "url2")
    combined_event = Event.from_events([event1, event2])

    calendars = Icalendar::Parser.new(combined_event.ical).parse
    assert_equal 1, calendars.length
    assert_equal 2, calendars.first.events.length
  end

  def test_filters_out_unfetchable_events
    event1 = Event.new(ICAL_DATA, "url1")
    unfetchable_event = UnfetchableEvent.new
    event2 = Event.new(ICAL_DATA, "url2")
    combined_event = Event.from_events([event1, unfetchable_event, event2])

    calendars = Icalendar::Parser.new(combined_event.ical).parse
    assert_equal 1, calendars.length
    assert_equal 2, calendars.first.events.length
  end
end
