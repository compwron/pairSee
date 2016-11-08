module PairSee
  class CardsPerPerson
    require_relative 'log_line'
    attr_reader :all

    def initialize(card_prefix, devs, log_lines)
      @all = _cards_per_person(card_prefix, devs, log_lines)
    end

    def _cards_per_person(card_prefix, devs, log_lines)
      devs.map do |dev|
        {dev => _cards_dev_worked_on(card_prefix, log_lines, dev)}
      end.inject({}) do |result, element|
        result.merge(element)
      end.map do |dev_name, cards_worked|
        {dev_name => cards_worked.uniq}
      end.inject({}) do |result, element|
        result.merge(element)
      end.map do |dev, cards|
        "#{dev}: [#{cards.size} cards] #{cards.sort.join(', ')}"
      end
    end

    def _cards_dev_worked_on(card_prefix, log_lines, dev)
      log_lines.select do |log_line|
        log_line.authored_by?(dev)
      end.map do |log_line|
        log_line.card_number(card_prefix)
      end.compact
    end
  end
end
