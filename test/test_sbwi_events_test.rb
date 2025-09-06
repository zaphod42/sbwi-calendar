require 'test_helper'
require 'sbwi_events'
require 'event'
require 'local_gateway'
require 'tracking_delayer'
require 'events_repository'
require 'tmpdir'
require 'fileutils'

class TestSbwiEvents < Minitest::Test
  def setup
    @repo_dir = Dir.mktmpdir
    @gateway = LocalGateway.new({
      "http://example.com/event1.ical" => "ical data 1",
      "http://example.com/event2.ical" => "ical data 2"
    })
    @delayer = TrackingDelayer.new
    @repository = EventsRepository.new(@repo_dir, @gateway, @delayer)
  end

  def teardown
    FileUtils.remove_entry(@repo_dir) if File.exist?(@repo_dir)
  end

  def test_returns_no_events_when_website_has_no_events
    sbwi_events = SbwiEvents.new('', @repository)
    assert_empty sbwi_events.events
  end

  def test_an_event_for_each_event_on_the_page
    html = '<a class="eventlist-meta-export-ical" href="http://example.com/event1.ical"></a><a class="eventlist-meta-export-ical" href="http://example.com/event2.ical"></a>'
    sbwi_events = SbwiEvents.new(html, @repository)
    assert_equal 2, sbwi_events.events.length
    assert_instance_of Event, sbwi_events.events.first
  end

  def test_delays_between_each_event
    delayer = TrackingDelayer.new
    html = '<a class="eventlist-meta-export-ical" href="http://example.com/event1.ical"></a><a class="eventlist-meta-export-ical" href="http://example.com/event2.ical"></a>'
    repository = EventsRepository.new(@repo_dir, @gateway, delayer)
    SbwiEvents.new(html, repository).events
    assert_equal 2, delayer.delays
  end

  def test_event_has_ical_data_from_link
    ical_url = "http://example.com/event.ical"
    ical_data = "BEGIN:VCALENDAR..."
    html = "<a class='eventlist-meta-export-ical' href='#{ical_url}'></a>"
    gateway = LocalGateway.new({ical_url => ical_data})
    repository = EventsRepository.new(@repo_dir, gateway, TrackingDelayer.new)
    sbwi_events = SbwiEvents.new(html, repository)
    assert_equal ical_data, sbwi_events.events.first.ical
    assert_equal ical_url, sbwi_events.events.first.url
  end
end
