module PairSee
  class CardKnowledgeSummary
    def initialize(card_number, commits_on_card_count, authors)
      @card_number = card_number
      @commits_on_card_count = commits_on_card_count
      @authors = authors
    end

    def has_debt
      @authors.count < 2
    end

    def pretty
      "#{@card_number} has #{@commits_on_card_count} commits with only #{@authors.count} committer(s) on the entire card"
    end
  end
end
