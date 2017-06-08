module PairSee
  class CardsPerPerson
    attr_reader :devs

    def initialize(log_lines, card_prefix, people)
      @log_lines = log_lines
      @card_prefix = card_prefix
      @devs = _active(people)
    end

    def cards_per_person
      @devs.map do |dev|
        {dev => _cards_dev_worked_on(@log_lines, dev)}
      end.inject({}) do |result, element|
        result.merge(element)
      end.map do |dev_name, cards_worked|
        {dev_name => cards_worked.uniq}
      end.inject({}) do |result, element|
        result.merge(element)
      end.sort do |a, b|
        a[1].size <=> b[1].size
      end.map do |dev, cards|
        "#{dev}: [#{cards.size} cards] #{cards.sort.join(', ')}"
      end
    end

    def _cards_dev_worked_on(log_lines, person)
      log_lines.select do |log_line|
        log_line.authored_by?(person)
      end.map do |log_line|
        log_line.card_number(@card_prefix)
      end.compact
    end

    def _active(people)
      people.select do |person|
        @log_lines.active? person
      end
    end
  end
end
