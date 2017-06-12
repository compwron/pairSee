module PairSee
  class SeerTop
    require_relative 'seer'

    attr_reader :seer

    def initialize(options)
      @seer = PairSee::Seer.new(options)
    end

    def commits_not_by_known_pair
      seer.commits_not_by_known_pair
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

    def cards_per_person
      seer.cards_per_person
    end

    def all_commits
      seer.all_commits
    end
  end
end
