require 'json'
require 'fileutils'
require 'digest'
require_relative 'event'
require_relative 'unfetchable_event'

class EventsRepository
  def initialize(repo_dir, gateway, delayer)
    unless File.directory?(repo_dir)
      raise ArgumentError, "Repository directory does not exist: #{repo_dir}"
    end
    @repo_dir = repo_dir
    @gateway = gateway
    @delayer = delayer
  end

  def save(event)
    return if event.is_a?(UnfetchableEvent)

    file_path = File.join(@repo_dir, "#{Digest::MD5.hexdigest(event.url)}.json")
    File.write(file_path, {ical: event.ical, url: event.url}.to_json)
  end

  def find(url)
    file_path = File.join(@repo_dir, "#{Digest::MD5.hexdigest(url)}.json")
    if File.exist?(file_path)
      saved_data = JSON.parse(File.read(file_path))
      Event.new(saved_data['ical'], saved_data['url'])
    else
      @delayer.pause
      ical_data = @gateway.get(url)
      if ical_data.nil?
        UnfetchableEvent.new
      else
        event = Event.new(ical_data, url)
        save(event)
        event
      end
    end
  end
end
