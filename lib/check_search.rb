require_relative '../env'
require "uri"

require_relative "check_file_parser"
require_relative "search_client"

class CheckSearch
  def initialize(authentication, search_host, filename, api_format, slow)
    @authentication, @filename, @api_format, @slow = authentication, filename, api_format, slow
    @base_url = URI.parse(search_host) + "search.json"
  end

  def call
    checks = CheckFileParser.new(File.open(@filename)).checks

    success_count = total_count = score = total_score = 0

    search_client = SearchClient.new(base_url: @base_url, authentication: @authentication, api_format: @api_format)
    checks.each do |check|
      results = search_client.search(check.search_term)

      found_index = results.index { |url|
        URI.parse(url).path == check.path
      }

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
