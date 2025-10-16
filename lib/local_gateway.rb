class LocalGateway
  def initialize(routes)
    @routes = routes
  end

  def get(url)
    @routes[url]
  end

  def post(url, body)
    @routes["POST:#{url}:#{URI.encode_www_form(body)}"]
  end
end
