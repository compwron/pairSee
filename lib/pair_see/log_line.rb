module PairSee
  class LogLine
    require 'time'
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def all_authors(people)
      people.select do |person|
        contains_any_of?(person.names)
      end
    end

    def authored_by?(*people)
      return false if people.empty?
      people.map do |person|
        contains_any_of?(person.names)
      end.all?
    end

    def contains_any_of?(names)
      names.any? {|name| line_contains_name(name)}
    end

    def line_contains_name(name)
      /(^|\s+|\W)#{name}(\s+|$|\W)/i =~ line
    end

    def contains_card?(card_prefix)
      line.match(card_prefix)
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

    def card_number(card_prefixes)
      card_prefixes.each do |cp|
        card_num = card_name([cp])
        return card_num.gsub(cp, '') if card_num
      end
      nil
    end

    def merge_commit?
      line.match('Merge remote-tracking branch') || line.match('Merge branch')
    end

    def date
      regex = /(\d{4}-\d{2}-\d{2})/
      matcher = line.match(regex)
      part_to_parse = matcher.nil? ? '' : (line.match regex)[1]
      Date.parse(part_to_parse)
    end

    def by_any?(devs)
      return false if devs.empty?
      devs.any? {|dev| authored_by?(dev)}
    end

    def to_s
      line
    end
  end
end
