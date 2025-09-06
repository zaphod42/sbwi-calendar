# frozen_string_literal: true

class TrackingDelayer
  attr_reader :delays

  def initialize
    @delays = 0
  end

  def pause
    @delays += 1
  end
end
