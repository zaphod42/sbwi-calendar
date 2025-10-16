require 'test_helper'
require 'calendar'
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

class TestCalendar < Minitest::Test
  def test_combines_events_into_a_calendar
    event1 = Calendar::Event.new('https://example.com', 'test', DateTime.now, DateTime.now, 'test event')
    event2 = Calendar::Event.new('https://example.com', 'another test', DateTime.now, DateTime.now, 'another test event')

    calendar = Calendar.from_events([event1, event2])

    assert_equal 2, calendar.ical_obj.events.length
  end

  def test_converts_to_ical_file_format
    event1 = Calendar::Event.new('https://example.com', 'test', DateTime.now, DateTime.now, 'test event')
    event2 = Calendar::Event.new('https://example.com', 'another test', DateTime.now, DateTime.now, 'another test event')

    calendars = Icalendar::Parser.new(Calendar.from_events([event1, event2]).to_ical).parse

    assert_equal 1, calendars.length
    assert_equal 2, calendars.first.events.length
  end
end
