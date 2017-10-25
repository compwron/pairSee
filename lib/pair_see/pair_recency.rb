module PairSee
  class PairRecency
    def initialize(log_lines, card_prefixes, people)
      @log_lines = log_lines
      @card_prefixes = card_prefixes
      @people = people
    end

    def pair_recency
      pairing_events = @people.map do |current_person|
        my_commits = @log_lines.select { |ll| ll.authored_by?(current_person) }

        most_recent_commits = {}
        @people.map do |pair|
          my_commits.each do |ll|
            if pair.display_name != current_person.display_name && ll.authored_by?(pair)
              most_recent_commits[pair] = [ll, pair] # TODO: make [ll, pair] and object? or make ll know devs in ll?
            end
          end
        end
        PairingEvent.new(current_person, most_recent_commits)
      end

      pairing_events.map(&:pretty) # TODO: make an object which extends Enum and holds pairing events
    end
  end
end
