Check = Struct.new(:search_term, :imperative, :path, :minimum_rank, :weight)

class Check
  def valid_imperative?
    ["should", "should not"].include?(imperative)
  end

  def valid_path?
    !path.nil? && !path.empty? && path.start_with?("/")
  end

  def valid_search_term?
    !search_term.nil? && !search_term.empty?
  end

  def valid_weight?
    weight > 0
  end

  def valid?
     valid_imperative? && valid_path? && valid_search_term? && valid_weight?
  end

  def positive_check?
    imperative == "should"
  end
end