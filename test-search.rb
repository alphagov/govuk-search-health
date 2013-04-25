#!/usr/bin/env ruby

require "optparse"
require "csv"
require "net/http"
require "uri"
require "json"
require "cgi"

if ENV["CREDENTIALS"]
  authentication = ENV["CREDENTIALS"].split(":")
else
  authentication = nil
end

search_host = ENV["SEARCH_BASE"] || "http://search.dev.gov.uk"
BASE_URL = URI.parse(search_host) + "search.json"

api_format = false
slow = false

OptionParser.new do |opts|
  opts.banner = "Usage: test-search.rb [options] TESTFILE"

  opts.on("-a", "--api-format", "Parse the content API response format") do |a|
    api_format = a
  end

  opts.on("-s", "--slow", "Slow down to avoid angering the rate limiter") do |s|
    slow = s
  end
end.parse!

filename = ARGV[0] || "weighted-search-terms.csv"

tests = []
CSV.open(filename, headers: true).each do |row|
  begin
    tests << [
      row["When I search for..."],
      row["Then I..."],
      row["see..."].sub(%r{https://www.gov.uk}, ""),
      row["in the top ... results"].to_i,
      row["Monthly searches"].to_i
    ]
  rescue
    STDERR.puts "Skipping incomplete row #{row}"
  end
end

success_count = total_count = score = total_score = 0

# Using Net::HTTP here because open-uri doesn't give us basic auth
http = Net::HTTP.new(BASE_URL.host, BASE_URL.port)
http.use_ssl = (BASE_URL.scheme == "https")

tests.each do |term, imperative, path, limit, weight|
  positive_test = case imperative
                  when "should"
                    true
                  when "should not"
                    false
                  else
                    raise "Gnnnaaaarrrggh!"
                  end

  if weight == 0
    puts "Skipping zero-weight test"
    next
  end

  request = Net::HTTP::Get.new((BASE_URL + "?q=#{CGI.escape(term)}").request_uri)
  request.basic_auth(*authentication) if authentication
  response = http.request(request)
  results = JSON.load(response.body)

  if api_format
    # Current bug: in the content API the hosts aren't always correct, so let's
    # just use the path for now and remove this when it's no longer needed
    found_index = results["results"].index { |result|
      URI.parse(result["web_url"]).path == path
    }
  else
    found_index = results.index { |result| result["link"] == path }
  end

  total_count += 1
  total_score += weight

  found_in_limit = found_index && found_index < limit
  success = positive_test ? found_in_limit : ! found_in_limit

  marker = "[#{weight}-POINT #{success ? "SUCCESS" : "FAILURE"}]"

  success_count += 1 if success
  score += weight if success

  if found_index
    expectation = positive_test ? "<= #{limit}" : "> #{limit}"
    puts "#{marker} Found '#{path}' for '#{term}' in position #{found_index + 1} (expected #{expectation})"
  else
    puts "#{marker} Didn't find '#{path}' in results for '#{term}'"
  end

  sleep 0.25 if slow
end

score_percentage = score.to_f / total_score * 100
puts "Score: #{score}/#{total_score} (#{format('%.2f', score_percentage)}%)"
puts "#{success_count} of #{total_count} succeeded"

