class Card
  attr_reader :card_name, :number_of_commits

  def initialize card_name, number_of_commits, first_date, last_date
    @card_name = card_name
    @number_of_commits = number_of_commits
    @first_date, @last_date = first_date, last_date
  end

  def duration
    (@first_date - @last_date).to_i + 1
  end

  def == other
    card_name == other.card_name
    number_of_commits == other.number_of_commits
  end
end