module PairSee
  class PairRecency
    def initialize(log_lines, card_prefixes, people)
      @log_lines = log_lines
      @card_prefixes = card_prefixes
      @people = people
    end

    def pair_recency
      pairing_events = @people.map {|current_person|
        my_commits = @log_lines.reject {|ll| !ll.authored_by?(current_person)}

        most_recent_commits = {}
        @people.map {|pair|
          my_commits.each {|ll|
            if pair.display_name != current_person.display_name && ll.authored_by?(pair)
              most_recent_commits[pair] = [ll, pair] # todo make [ll, pair] and object? or make ll know devs in ll?
            end
          }

        }
        PairingEvent.new(current_person, most_recent_commits)
      }

      pairing_events.map {|pe| pe.pretty} # todo make an object which extends Enum and holds pairing events
    end
  end
end
