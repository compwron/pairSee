module PairSee
  class CardsPerPerson
    attr_reader :people

    def initialize(log_lines, card_prefix, people)
      @log_lines = log_lines
      @card_prefix = card_prefix
      @people = _active(people)
    end

    def cards_per_person
      all = Hash[people.map { |key, _| [key, []] }]

      @log_lines.each do |log_line| # loop through the biggest list only once
        all.each do |person, _|
          all[person] << log_line.card_number(@card_prefix) if log_line.authored_by? person
        end
      end

      all.each { |_, card_names| card_names.uniq! }
      all.sort_by { |_, card_names| card_names.count }.map do |person, card_names|
        sorted = card_names.compact.sort_by(&:to_i)
        "#{person}: [#{card_names.size} cards] #{sorted.join(', ')}"
      end
    end

    def _active(people)
      people.select do |person|
        @log_lines.active? person
      end
    end
  end
end
