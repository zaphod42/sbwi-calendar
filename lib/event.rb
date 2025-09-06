class Event
  attr_reader :ical, :url

  def initialize(ical, url)
    @ical = ical
    @url = url
  end

  def self.from_events(events)
    combined_ical = events.reject { |event| event.is_a?(UnfetchableEvent) }.map(&:ical).join("\n")
    # For now, we'll use a placeholder URL for the combined event.
    # This might need to be revisited later if a combined event needs a meaningful URL.
    new(combined_ical, "combined_event_url")
  end
end
