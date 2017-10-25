module PairSee
  class CardsPerPerson
    attr_reader :people, :cards_per_person, :dev_pairs

    def initialize(log_lines, card_prefix, people)
      @people = _active(people, log_lines)
      @cards_per_person = _cards_per_person(log_lines, card_prefix)
      @dev_pairs = @people.combination(2)
    end

    private

    def _cards_per_person(log_lines, card_prefix)
      all = _people_hash
      _populate_card_numbers(all, log_lines, card_prefix)
      _unique_cards_per_person(all)
      _sort_by_cards_count(all)
    end

    def _sort_by_cards_count(all)
      all.sort_by { |_, card_names| card_names.count }.map do |person, card_names|
        sorted = card_names.compact.sort_by(&:to_i)
        "#{person}: [#{card_names.size} cards] #{sorted.join(', ')}"
      end
    end

    def _unique_cards_per_person(all)
      all.each { |_, card_names| card_names.uniq! }
    end

    def _populate_card_numbers(all, log_lines, card_prefix)
      log_lines.each do |log_line| # loop through the biggest list only once
        all.each do |person, _|
          if log_line.authored_by? person
            all[person] << log_line.card_number(card_prefix)
          end
        end
      end
    end

    def _people_hash
      Hash[people.map { |key, _| [key, []] }]
    end

    def _active(people, log_lines)
      people.select do |person|
        log_lines.active? person
      end
    end
  end
end
