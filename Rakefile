require_relative 'env'
require_relative 'lib/check_search'

Logging.logger.root.level = :info
Logging.logger.root.add_appenders(Logging.appenders.stdout)

desc "Downloads checks to run from Google Docs. Optionally specify indices in INDICES environment variable."
task :download_checks do
  require 'time'
  require 'open-uri'
  require 'fileutils'

  indices = if ENV["INDICES"]
    ENV["INDICES"].split(",")
  else
    ["mainstream", "detailed", "government"]
  end

  gids_by_index = {
    "mainstream" => "0",
    "detailed"   => "3",
    "government" => "2"
  }

  gids_by_index.each do |index, gid|
    if indices.include?(index)
      # Link generated by going to:
      #   File
      #     Publish to the web
      #       Get a link to the published data
      #          then choose CSV
      io = open("https://docs.google.com/spreadsheet/pub?key=0AmD7K4ab1dYrdDR5c2tITTNHRUZqajFTTU8wODAzZ1E&single=true&gid=#{gid}&output=csv")

      file = File.new("data/downloaded-#{index}-weighted-search-terms-#{Time.now.utc.iso8601}.csv", "wb")
      file.write(io.read)
      file.close

      # Create a symlink called "#{index}-weighted-search-terms.csv" pointing at the file just downloaded
      `cd data && ln -sf #{File.basename(file)} #{index}-weighted-search-terms.csv`
      puts "Downloaded data/#{index}-weighted-search-terms.csv"
    end
  end
end

desc "Runs search health check using weighted check data. Optionally specify indices in INDICES environment variable."
task :check_search do
  if ENV["CREDENTIALS"]
    authentication = ENV["CREDENTIALS"].split(":")
  else
    authentication = nil
  end

  search_host = ENV["SEARCH_BASE"] || "http://search.dev.gov.uk"

  slow = !ENV["SLOW"].nil?

  indices = if ENV["INDICES"]
    ENV["INDICES"].split(",")
  else
    ["mainstream", "detailed", "government"]
  end

  format = ENV["FORMAT"] || "json"

  calculators = indices.map do |index|
    puts "Running checks against #{index} index"

    filename = "data/#{index}-weighted-search-terms.csv"
    test_search = CheckSearch.new(authentication, search_host, filename, index, slow, format)
    calculator = test_search.call

    puts "Outcome from checks against #{index} index"
    calculator.summarise
    calculator
  end

  puts "Overall outcome:"
  calculators.reduce(&:+).summarise
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
