#!/usr/bin/env ruby

require_relative 'lib/aura_events'
require_relative 'lib/http_gateway'
require_relative 'lib/delayed_gateway'
require_relative 'lib/random_delayer'
require_relative 'lib/calendar'

gateway = HttpGateway.new('https://sambeaufordwoodworkingins.my.site.com/ce/aura?r=1&aura.ApexAction.execute=1')
aura = AuraEvents.new(DelayedGateway.new(gateway, RandomDelayer.new(1000, 4000)))

puts Calendar.from_events(aura.events.to_a).to_ical