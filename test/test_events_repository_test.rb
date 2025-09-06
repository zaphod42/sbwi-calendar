require 'test_helper'
require 'events_repository'
require 'event'
require 'json'
require 'tmpdir'
require 'fileutils'
require 'digest'
require 'local_gateway'
require 'tracking_delayer'
require 'unfetchable_event'

class TestEventsRepository < Minitest::Test
  def test_saves_event_to_disk
    Dir.mktmpdir do |repo_dir|
      event = Event.new("ical data", "http://example.com/event1")
      repository = EventsRepository.new(repo_dir, LocalGateway.new({}), TrackingDelayer.new)
      repository.save(event)

      file_path = File.join(repo_dir, "#{Digest::MD5.hexdigest(event.url)}.json")
      assert File.exist?(file_path)
      saved_data = JSON.parse(File.read(file_path))
      assert_equal event.ical, saved_data['ical']
      assert_equal event.url, saved_data['url']
    end
  end

  def test_finds_event_from_disk
    Dir.mktmpdir do |repo_dir|
      event = Event.new("ical data", "http://example.com/event1")
      repository = EventsRepository.new(repo_dir, LocalGateway.new({}), TrackingDelayer.new)
      repository.save(event)

      found_event = repository.find(event.url)
      assert_equal event.ical, found_event.ical
      assert_equal event.url, found_event.url
    end
  end

  def test_finds_event_from_gateway_and_saves_to_disk
    Dir.mktmpdir do |repo_dir|
      ical_url = "http://example.com/event2"
      ical_data = "BEGIN:VCALENDAR..."
      gateway = LocalGateway.new({ical_url => ical_data})
      repository = EventsRepository.new(repo_dir, gateway, TrackingDelayer.new)

      found_event = repository.find(ical_url)
      assert_equal ical_data, found_event.ical
      assert_equal ical_url, found_event.url

      file_path = File.join(repo_dir, "#{Digest::MD5.hexdigest(ical_url)}.json")
      assert File.exist?(file_path)
      saved_data = JSON.parse(File.read(file_path))
      assert_equal ical_data, saved_data['ical']
      assert_equal ical_url, saved_data['url']
    end
  end

  def test_finds_unfetchable_event_from_gateway_and_does_not_save_to_disk
    Dir.mktmpdir do |repo_dir|
      ical_url = "http://example.com/unfetchable_event"
      gateway = LocalGateway.new({ical_url => nil})
      repository = EventsRepository.new(repo_dir, gateway, TrackingDelayer.new)

      found_event = repository.find(ical_url)
      assert_instance_of UnfetchableEvent, found_event

      file_path = File.join(repo_dir, "#{Digest::MD5.hexdigest(ical_url)}.json")
      refute File.exist?(file_path)
    end
  end
end
