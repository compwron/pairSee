module PairSee
  class LogLine
    require 'time'
    attr_reader :line, :date, :card_number

    def initialize(line)
      @line = line
      @date = _get_date(line)
    end

    def all_authors(people)
      people.select do |person|
        _contains_any_of?(person.names)
      end
    end

    def authored_by?(*people)
      return false if people.empty?
      people.map do |person|
        _contains_any_of?(person.names)
      end.all?
    end

    def card_number(card_prefixes)
      card_prefixes.each do |cp|
        card_num = card_name([cp])
        return card_num.gsub(cp, '') if card_num
      end
      nil
    end

    def contains_card_name?(card_name)
      git_regex = /#{card_name}[\]\s\[,:]/
      git_matcher = line.match(git_regex)
      !git_matcher.nil?
    end

    def card_name(card_prefixes)
      card_prefixes.each do |cp|
        regex = /(#{cp}\d+)/
        matcher = line.match(regex)
        return (line.match regex)[1] unless matcher.nil?
      end
      nil
    end

    def by_any?(devs)
      return false if devs.empty?
      devs.any? {|dev| authored_by?(dev)}
    end

    def contains_card?(card_prefix)
      line.match(card_prefix)
    end

    def to_s
      line
    end

    private

    def _get_date(line)
      regex = /(\d{4}-\d{2}-\d{2})/
      matcher = line.match(regex)
      part_to_parse = matcher.nil? ? '' : (line.match regex)[1]
      Date.parse(part_to_parse)
    end

    def _contains_any_of?(names)
      names.any? {|name| _line_contains_name(name)}
    end

    def _line_contains_name(name)
      /(^|\s+|\W)#{name}(\s+|$|\W)/i =~ line
    end
  end
end
