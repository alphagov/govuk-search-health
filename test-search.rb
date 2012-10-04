#!/usr/bin/env ruby

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
BASE_URL = URI.parse(search_host) + "/search.json"

filename = ARGV[0] || "search-terms.txt"

tests = if filename.end_with? ".csv"
  CSV.open(filename, headers: true).map { |row|
    [
      row["When I search for..."],
      row["Then I..."],
      row["see..."].sub(%r{https://www.gov.uk}, ""),
      row["in the top ... results"].to_i,
      row["Total monthly searches"].to_i
    ]
  }
else
  open(filename).each_line.map { |line|
    term, imperative, path, limit = line.split('|').map(&:strip).reject(&:empty?)
    limit = limit.to_i
    [term, imperative, path, limit.to_i, 1]
  }
end

success_count = total_count = score = total_score = 0

# Using Net::HTTP here because open-uri doesn't give us basic auth
http = Net::HTTP.new(BASE_URL.host, BASE_URL.port)

tests.each do |term, imperative, path, limit, weight|
  positive_test = case imperative
                  when "should"
                    true
                  when "should not"
                    false
                  else
                    raise "Gnnnaaaarrrggh!"
                  end

  request = Net::HTTP::Get.new((BASE_URL + "?q=#{CGI.escape(term)}").request_uri)
  request.basic_auth(*authentication) if authentication
  response = http.request(request)
  results = JSON.load(response.body)

  found_index = results.index { |result| result["link"] == path }

  total_count += 1
  total_score += weight

  found_in_limit = found_index && found_index < limit
  success = positive_test ? found_in_limit : ! found_in_limit

  marker = "[#{weight}-POINT #{success ? "SUCCESS" : "FAILURE"}]"

  success_count += 1 if success
  score += weight if success

  if found_index
    puts "#{marker} Found '#{path}' for '#{term}' in position #{found_index + 1} (expected <= #{limit})"
  else
    puts "#{marker} Didn't find '#{path}' in results for '#{term}'"
  end
end

score_percentage = score.to_f / total_score * 100
puts "Score: #{score}/#{total_score} (#{format('%.2f', score_percentage)}%)"
puts "#{success_count} of #{total_count} succeeded"

