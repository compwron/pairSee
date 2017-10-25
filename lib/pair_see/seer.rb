module PairSee
  class Seer
    require_relative 'too_much_stuff'

    attr_reader :seer

    def initialize(options)
      @repo_locations = options[:repo_locations]
      @after_date = options[:after_date]
      @card_prefix = options[:card_prefix]
      @names = options[:names]
      @seer = PairSee::TooMuchStuff.new(options)
      @log_lines = LogLineParse.new(@repo_locations, @after_date).log_lines
    end

    def commits_not_by_known_pair
      seer.commits_not_by_known_person
    end

    def all_most_recent_commits
      seer.all_most_recent_commits
    end

    def recommended_pairings
      seer.recommended_pairings
    end

    def pretty_card_data
      seer.pretty_card_data
    end

    def pretty_card_data_by_commits
      seer.pretty_card_data_by_commits
    end

    def all_commits
      seer.all_commits
    end

    def cards_per_person
      CardsPerPerson.new(@log_lines, @card_prefix, @names).cards_per_person
    end

    def knowledge_debt
      KnowledgeDebt.new(@log_lines, @card_prefix, @names).knowledge_debt
    end

    def pair_recency
      PairRecency.new(@log_lines, @card_prefix, @names).pair_recency
    end
  end
end
