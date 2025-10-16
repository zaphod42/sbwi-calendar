# frozen_string_literal: true

class DelayedGateway
  def initialize(gateway, delayer)
    @gateway = gateway
    @delayer = delayer
  end

  def get(url)
    @delayer.pause
    @gateway.get(url)
  end

  def post(url, body)
    @delayer.pause
    @gateway.post(url, body)
  end
end
