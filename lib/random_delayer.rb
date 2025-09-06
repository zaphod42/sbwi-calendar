# frozen_string_literal: true

class RandomDelayer
  def initialize(min_ms, max_ms)
    @min_ms = min_ms
    @max_ms = max_ms
  end

  def pause
    random_ms_to_sleep = Random.rand(@min_ms..@max_ms)
    sleep(ms_to_s(random_ms_to_sleep))
  end

  private

  def ms_to_s(ms)
    ms / 1000.0
  end
end
