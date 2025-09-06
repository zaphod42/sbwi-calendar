class LocalGateway
  def initialize(routes)
    @routes = routes
  end

  def get(url)
    @routes[url]
  end
end
