require_relative 'check'
require "csv"

class CheckFileParser
  def initialize(file)
    @file = file
  end

  def checks
    checks = []
    CSV.parse(@file, headers: true).each do |row|
      begin
        check = Check.new
        check.search_term      = row["When I search for..."]
        check.imperative        = row["Then I..."]
        check.path     = row["see..."].sub(%r{https://www.gov.uk}, "")
        check.minimum_rank     = Integer(row["in the top ... results"])
        check.weight = parse_integer_with_comma(row["Monthly searches"])
        if check.valid?
          checks << check
        end
      rescue => e
        logger.warn("Skipping invalid or incomplete row: #{row} because: #{e.message}")
      end
    end
    checks
  end

  private
    def parse_integer_with_comma(raw)
      Integer(raw.gsub(",", ""))
    end

    def logger
      Logging.logger[self]
    end
end
