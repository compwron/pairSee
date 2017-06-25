module PairSee
  class CardsPerPerson
    attr_reader :people

    def initialize(log_lines, card_prefix, people)
      @log_lines = log_lines
      @card_prefix = card_prefix
      @people = _active(people)
    end

    def cards_per_person
      all = people_hash
      populate_card_numbers(all)
      unique_cards_per_person(all)
      sort_by_cards_count(all)
    end

    def sort_by_cards_count(all)
      all.sort_by {|_, card_names| card_names.count}.map do |person, card_names|
        sorted = card_names.compact.sort_by(&:to_i)
        "#{person}: [#{card_names.size} cards] #{sorted.join(', ')}"
      end
    end

    def unique_cards_per_person(all)
      all.each {|_, card_names| card_names.uniq!}
    end

    def populate_card_numbers(all)
      @log_lines.each do |log_line| # loop through the biggest list only once
        all.each do |person, _|
          if log_line.authored_by? person then
            all[person] << log_line.card_number(@card_prefix)
          end
        end
      end
    end

    def people_hash
      Hash[people.map {|key, _| [key, []]}]
    end

    def _active(people)
      people.select do |person|
        @log_lines.active? person
      end
    end
  end
end
