class Card
  attr_reader :card_name, :number_of_commits

  def initialize card_name, number_of_commits
    @card_name = card_name
    @number_of_commits = number_of_commits
  end

  # def first_commit_date
  # end

  # def last_commit_date
  # end

  # def duration
  # end

  def == other
    card_name == other.card_name
    number_of_commits == other.number_of_commits
  end
end