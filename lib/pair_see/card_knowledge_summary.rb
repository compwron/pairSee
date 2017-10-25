module PairSee
  class CardKnowledgeSummary
    include Comparable
    attr_reader :commits_on_card_count, :authors

    def initialize(card_number, commits_on_card_count, authors)
      @card_number = card_number
      @commits_on_card_count = commits_on_card_count
      @authors = authors
    end

    def has_debt
      @authors.count < 2
    end

    def pretty
      pretty_author_names = @authors.map {|a| a.to_s}.join
      "#{@card_number} has #{@commits_on_card_count} commits with only #{@authors.count} committer(s) #{pretty_author_names } on the entire card"
    end

    def authors_list
      @authors.sort.join(" ")
    end
  end
end
