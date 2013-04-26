require_relative 'env'
require_relative 'lib/check_search'

task :check_search do
  if ENV["CREDENTIALS"]
    authentication = ENV["CREDENTIALS"].split(":")
  else
    authentication = nil
  end

  search_host = ENV["SEARCH_BASE"] || "http://search.dev.gov.uk"

  api_format = !ENV["API_FORMAT"].nil?
  slow = !ENV["SLOW"].nil?

  filename = "weighted-search-terms.csv"
  test_search = CheckSearch.new(authentication, search_host, filename, api_format, slow)
  test_search.call
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
