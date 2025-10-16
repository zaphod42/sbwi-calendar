require 'net/http'
require 'uri'

class HttpGateway
  def initialize(base_url)
    @base_url = base_url
  end

  def get(url)
    absolute_url = URI.join(@base_url, url)
    response = Net::HTTP.get_response(absolute_url)
    if response.is_a?(Net::HTTPSuccess)
      response.body
    else
      nil
    end
  end

  def post(url, body)
    absolute_url = URI.join(@base_url, url)
    response = Net::HTTP.post(absolute_url, URI.encode_www_form(body))
    if response.is_a?(Net::HTTPSuccess)
      response.body
    else
      nil
    end
  end
end
