module PairSee
  class CardsPerPerson
    attr_reader :people

    def initialize(log_lines, card_prefix, people)
      @log_lines = log_lines
      @card_prefix = card_prefix
      @people = _active(people)
    end

    def cards_per_person
      all = Hash[people.map {|key, _| [key, []]}]

      @log_lines.each {|log_line| # loop through the biggest list only once
        all.each {|person, _|
          if log_line.authored_by? person
            all[person] << log_line.card_number(@card_prefix)
          end
        }
      }

      all.each {|_, card_names| card_names.uniq!}
      all.sort_by {|_, card_names| card_names.count}.map {|person, card_names|
        "#{person}: [#{card_names.size} cards] #{card_names.sort.join(', ')}"
      }
    end

    def _active(people)
      people.select do |person|
        @log_lines.active? person
      end
    end
  end
end
