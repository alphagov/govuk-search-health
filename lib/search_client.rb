require "uri"
require "net/http"
require "json"
require "cgi"

class SearchClient
  def initialize(options={})
    @base_url       = options[:base_url] || URI.parse("https://www.gov.uk/api/")
    @authentication = options[:authentication] || nil
    @api_format     = options[:api_format] || true
  end

  def search(term)
    request = Net::HTTP::Get.new((@base_url + "?q=#{CGI.escape(term)}").request_uri)
    request.basic_auth(*@authentication) if @authentication
    response = http_client.request(request)
    json_response = JSON.parse(response.body)

    if @api_format
      json_response["results"].map { |result| result["web_url"] }
    else
      json_response.map { |result| result["link"] }
    end
  end

  private
    def http_client
      @_http_client ||= begin
        http = Net::HTTP.new(@base_url.host, @base_url.port)
        http.use_ssl = (@base_url.scheme == "https")
        http
      end
    end
end
