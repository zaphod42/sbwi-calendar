#!/usr/bin/env ruby

require_relative 'lib/sbwi_events'
require_relative 'lib/http_gateway'
require_relative 'lib/event'
require_relative 'lib/random_delayer'
require_relative 'lib/events_repository'
require 'fileutils'

SBWI_BASE_URL = "https://sbwi.edu"
REPO_DIR = "tmp/events"

FileUtils.mkdir_p(REPO_DIR)

gateway = HttpGateway.new(SBWI_BASE_URL)
repository = EventsRepository.new(REPO_DIR, gateway, RandomDelayer.new(500, 2500))

html = gateway.get("/learn-woodworking")
sbwi_events = SbwiEvents.new(html, repository)
events = sbwi_events.events

combined_event = Event.from_events(events)

puts combined_event.ical
