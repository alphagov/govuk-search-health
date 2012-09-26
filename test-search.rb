#!/usr/bin/env ruby

require "csv"
require "open-uri"
require "json"
require "cgi"

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

tests.each do |term, imperative, path, limit, weight|
  unless imperative == "should"
    puts "[SKIPPING] negative check for '#{term}'"
    next
  end
  results = JSON.load(open("http://search.dev.gov.uk/search.json?q=#{CGI.escape(term)}"))
  found_index = results.index { |result| result["link"] == path }

  total_count += 1
  total_score += weight

  success = found_index && found_index < limit
  marker = "[#{weight}-POINT #{success ? "SUCCESS" : "FAILURE"}]"
  if found_index
    puts "#{marker} Found '#{path}' for '#{term}' in position #{found_index + 1} (expected <= #{limit})"
    success_count += 1 if success
    score += weight if success
  else
    puts "#{marker} Didn't find '#{path}' in results for '#{term}'"
  end
end

score_percentage = score.to_f / total_score * 100
puts "Score: #{score}/#{total_score} (#{format('%.2f', score_percentage)}%)"
puts "#{success_count} of #{total_count} succeeded"

