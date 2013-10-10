require 'time'
class LogLine
  attr_reader :line

  def initialize line
    @line = line
  end

  def authored_by?(svn_committers, *people)
    name_in_line = people.all? { |person|
      /#{person}/i =~ line
    }
    if (name_in_line)
      return true
    end

    if (!svn_committers.empty?)
      return people.all? { |person|
        id = svn_committers[person]
        id != nil && !(/#{id}/i =~ line).nil?
      }
    end
    return false
  end

  def contains_card? card_prefix
    line.match(card_prefix)
  end

  def contains_card_name? card_name
    git_regex = /#{card_name}[\]\s\[,:]/
    git_matcher = line.match(git_regex)

    svn_regex = /\[#{card_name}\]/
    svn_matcher = line.match(svn_regex)

    !git_matcher.nil? || !svn_matcher.nil?
  end

  def card_name card_prefix
    regex = /(#{card_prefix}\d+)/
    matcher = line.match(regex)
    matcher.nil? ? nil : (line.match regex)[1]
  end

  def merge_commit?
    line.match("Merge remote-tracking branch") || line.match("Merge branch")
  end

  def date
    regex = /(\d{4}-\d{2}-\d{2})/
    matcher = line.match(regex)
    part_to_parse = matcher.nil? ? "" : (line.match regex)[1]
    Date.parse(part_to_parse)
  end

  def not_by_pair? devs, svn_committers=[]
    devs.any? { |dev| authored_by?(svn_committers, dev) || merge_commit? }
  end

  def to_s
    line
  end
end
