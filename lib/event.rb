require 'icalendar'

class Event
  attr_reader :ical, :url

  def initialize(ical, url)
    @ical = ical
    @url = url
  end

  def parsed
    Icalendar::Parser.new(ical).parse.first
  end

  def self.from_events(events)
    icals = events.reject { |event| event.is_a?(UnfetchableEvent) }.map(&:parsed)

    representative_ical = icals.first

    combined_ical = Icalendar::Calendar.new
    combined_ical.version = representative_ical.version
    combined_ical.prodid = representative_ical.prodid

    icals.each do |ical|
      ical.events.each { |event| combined_ical.add_event(event) }
    end

    # For now, we'll use a placeholder URL for the combined event.
    # This might need to be revisited later if a combined event needs a meaningful URL.
    new(combined_ical.to_ical, "combined_event_url")
  end
end
