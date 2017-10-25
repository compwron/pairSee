module PairSee
  class KnowledgeDebt
    def initialize(log_lines, card_prefixes, people)
      @log_lines = log_lines
      @card_prefixes = card_prefixes
      @people = people
    end

    def knowledge_debt
      # TODO: do something here with percentage knowledge per card
      commits_per_card.map do |card_name, commits|
        authors_per_commit = commits.map do |log_line|
          log_line.all_authors(@people)
        end
        authors = authors_per_commit.flatten.uniq
        CardKnowledgeSummary.new(card_name, commits.count, authors)
      end.select(&:has_debt).sort_by(&:authors_list).map(&:pretty)
    end

    def commits_per_card
      card_to_commits = {}

      @log_lines.each do |ll|
        cn = ll.card_number(@card_prefixes)
        card_to_commits[cn] = [] unless card_to_commits[cn]
        card_to_commits[cn] << ll
      end
      card_to_commits
    end
  end
end
