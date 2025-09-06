require 'nokogiri'
require_relative 'event'
require_relative 'events_repository'

class SbwiEvents
  def initialize(html, repository)
    @html = html
    @repository = repository
  end

  def events
    doc = Nokogiri::HTML(@html)
    doc.css('.eventlist-meta-export-ical[href]').map do |link|
      ical_url = link['href']
      @repository.find(ical_url)
    end.compact
  end
end
