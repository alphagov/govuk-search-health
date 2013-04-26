require_relative '../env'

require "csv"
require "net/http"
require "uri"
require "json"
require "cgi"

require_relative "check_file_parser"

class CheckSearch
  def initialize(authentication, search_host, filename, api_format, slow)
    @authentication, @filename, @api_format, @slow = authentication, filename, api_format, slow
    @base_url = URI.parse(search_host) + "search.json"
  end

  def call
    checks = CheckFileParser.new(File.open(@filename)).checks

    success_count = total_count = score = total_score = 0

    # Using Net::HTTP here because open-uri doesn't give us basic auth
    http = Net::HTTP.new(@base_url.host, @base_url.port)
    http.use_ssl = (@base_url.scheme == "https")

    checks.each do |check|
      request = Net::HTTP::Get.new((@base_url + "?q=#{CGI.escape(check.search_term)}").request_uri)
      request.basic_auth(*@authentication) if @authentication
      response = http.request(request)
      results = JSON.load(response.body)

      if @api_format
        # Current bug: in the content API the hosts aren't always correct, so let's
        # just use the path for now and remove this when it's no longer needed
        found_index = results["results"].index { |result|
          URI.parse(result["web_url"]).path == check.path
        }
      else
        found_index = results.index { |result| result["link"] == check.path }
      end

      total_count += 1
      total_score += check.weight

      found_in_limit = found_index && found_index < check.weight
      success = check.positive_check? ? found_in_limit : ! found_in_limit

      marker = "[#{check.weight}-POINT #{success ? "SUCCESS" : "FAILURE"}]"

      success_count += 1 if success
      score += check.weight if success

      if found_index
        expectation = check.positive_check? ? "<= #{check.minimum_rank}" : "> #{check.minimum_rank}"
        puts "#{marker} Found '#{check.path}' for '#{check.search_term}' in position #{found_index + 1} (expected #{expectation})"
      else
        puts "#{marker} Didn't find '#{check.path}' in results for '#{check.search_term}'"
      end

      sleep 0.25 if @slow
    end

    score_percentage = score.to_f / total_score * 100
    puts "Score: #{score}/#{total_score} (#{format('%.2f', score_percentage)}%)"
    puts "#{success_count} of #{total_count} succeeded"
  end
end
