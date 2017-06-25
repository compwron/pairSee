module PairSee
  class Seer
    require_relative 'too_much_stuff'

    attr_reader :seer

    def initialize(options)
      @seer = PairSee::TooMuchStuff.new(options)
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

    def cards_per_person
      seer.cards_per_person
    end

    def all_commits
      seer.all_commits
    end
  end
end
