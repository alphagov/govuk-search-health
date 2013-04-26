require_relative '../env'
require "uri"

require_relative "check_file_parser"
require_relative "search_client"
require_relative "calculator"

class CheckSearch
  def initialize(authentication, search_host, filename, api_format, slow)
    @authentication, @filename, @api_format, @slow = authentication, filename, api_format, slow
    @base_url = URI.parse(search_host) + "search.json"
  end

  def call
    checks.each do |check|
      search_results = search_client.search(check.search_term)
      result = check.result(search_results)
      calculator.add(result)

      sleep 0.25 if @slow
    end
    calculator.summarise
  end

  private
    def checks
      CheckFileParser.new(File.open(@filename)).checks
    end

    def search_client
      @_search_client ||= SearchClient.new(base_url: @base_url, authentication: @authentication, api_format: @api_format)
    end

    def calculator
      @_calculator ||= Calculator.new
    end
end
