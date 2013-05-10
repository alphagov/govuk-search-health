require_relative "../test_helper"

class CalculatorTest < MiniTest::Unit::TestCase
  context "+" do
    should "return a new Calculator" do
      c = Calculator.new + Calculator.new
      assert c.is_a?(Calculator)
    end

    should "sum the attributes" do
      c = Calculator.new(1,20,300,4000) + Calculator.new(2,30,400,5000)
      assert_equal 3, c.success_count
      assert_equal 50, c.total_count
      assert_equal 700, c.score
      assert_equal 9000, c.possible_score
    end

    should "summarise results" do
      c = Calculator.new(1,2,3,4)
      Logging.logger[c].expects(:info).with("Score: 3/4 (75.00%)")
      Logging.logger[c].expects(:info).with("1 of 2 succeeded")
      c.summarise
    end

    should "override the description" do
      c = Calculator.new(1,2,3,4)
      Logging.logger[c].expects(:info).with("Awesomeness: 3/4 (75.00%)")
      Logging.logger[c].expects(:info).with("1 of 2 succeeded")
      c.summarise("Awesomeness")
    end
  end
end
