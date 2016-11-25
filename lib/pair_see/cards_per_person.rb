module PairSee
  class CardsPerPerson
    attr_reader :devs

    def initialize(log_lines, options)
      @log_lines = log_lines
      @options = options
      @devs = _active(options[:names])
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
      end.map do |dev, cards|
        "#{dev}: [#{cards.size} cards] #{cards.sort.join(', ')}"
      end
    end

    def _cards_dev_worked_on(log_lines, dev)
      log_lines.select do |log_line|
        log_line.authored_by?(dev)
      end.map do |log_line|
        log_line.card_number(@options[:card_prefix])
      end.compact
    end

    def _active(devs)
      devs.select do |dev|
        _is_active?(dev)
      end
    end

    def _is_active?(dev)
      @log_lines.active? dev
    end
  end
end
