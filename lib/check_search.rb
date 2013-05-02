require_relative '../env'
require "uri"

class CheckSearch
  def initialize(authentication, search_host, filename, index, slow)
    @authentication, @filename, @index, @slow = authentication, filename, index, slow
    @base_url = URI.parse(search_host) + "search.json"
  end

  def call
    checks.each do |check|
      search_results = search_client.search(check.search_term)
      result = check.result(search_results)
      calculator.add(result)

      sleep 0.25 if @slow
    end
    calculator
  end

  private
    def checks
      CheckFileParser.new(File.open(@filename)).checks
    end

    def search_client
      @_search_client ||= JSONSearchClient.new(base_url: @base_url, index: @index, authentication: @authentication)
    end

    def calculator
      @_calculator ||= Calculator.new
    end
end
