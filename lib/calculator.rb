class Calculator
  def initialize
    @success_count = 0
    @total_count = 0
    @score = 0
    @possible_score = 0
  end

  def add(result)
    @total_count += 1
    @possible_score += result.possible_score
    @success_count += 1 if result.success
    @score += result.score
  end

  def summarise
    score_percentage = @score.to_f / @possible_score * 100
    puts "Score: #{@score}/#{@possible_score} (#{format('%.2f', score_percentage)}%)"
    puts "#{@success_count} of #{@total_count} succeeded"
  end
end
