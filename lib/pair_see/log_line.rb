module PairSee
  class LogLine
    require 'time'
    attr_reader :line

    def initialize(line)
      @line = line
    end

    def authored_by?(*people)
      if people.size == 0
        return false
      end

      people.each {|person|
        person.names.each {|name|
          if !line_contains_name(name)
            return false
          end
        }
      }
      return true
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
      card_prefixes.each {|cp|
        regex = /(#{cp}\d+)/
        matcher = line.match(regex)
        if (!matcher.nil?)
          return (line.match regex)[1]
        end
      }
      return nil
    end

    def card_number(card_prefixes)
      card_prefixes.each {|cp|
        card_num = card_name([cp])
        if (card_num)
          return card_num.gsub(cp, '')
        end
      }
      return nil
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

    def not_by_pair?(devs)
      devs.any? {|dev| authored_by?(dev) || merge_commit?}
    end

    def to_s
      line
    end
  end
end
