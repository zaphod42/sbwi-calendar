require 'icalendar'

class Calendar
  attr_reader :ical_obj

  def initialize(ical)
    @ical_obj = ical
  end

  def self.from_events(events)
    combined_ical = Icalendar::Calendar.new

    events.each do |event|
      combined_ical.add_event(event.to_ical)
    end

    new(combined_ical)
  end

  def to_ical
    @ical_obj.to_ical
  end

  Event = Struct.new(:url, :title, :start_datetime, :end_datetime, :description) do
    def to_ical
      ical = Icalendar::Event.new
      ical.dtstart = start_datetime
      ical.dtend = end_datetime
      ical.summary = title
      ical.description = description
      ical.url = url
      ical
    end
  end
end
