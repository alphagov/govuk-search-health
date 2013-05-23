require_relative '../env'
require "uri"

class CheckSearch

  attr_reader :search_client

  def initialize(authentication, search_host, filename, index, slow, format)
    @filename, @index, @slow = filename, index, slow

    url = base_url(search_host, format)

    @search_client = client_class(format).new(
      base_url: url,
      index: @index,
      authentication: authentication
    )
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
      CheckFileParser.new(File.open(@filename)).checks.sort { |a,b| b.weight <=> a.weight }
    end

    def client_class(format)
      case format
      when "json"
        JSONSearchClient
      when "html"
        HTMLSearchClient
      else
        raise ArgumentError, "Unknown format '#{format}'"
      end
    end

    def base_url(search_host, format)
      case format
      when "json"
        URI.parse(search_host) + "search.json"
      when "html"
        URI.parse(search_host) + "search"
      else
        raise ArgumentError, "Unknown format '#{format}'"
      end
    end

    def calculator
      @_calculator ||= Calculator.new
    end
end
