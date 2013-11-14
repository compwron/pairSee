require 'time'
class LogLine
  attr_reader :line

  def initialize line
    @line = line
  end

  def authored_by?(svn_committers, *people)
    return svn_committers.empty? ? git_authored_by?(people) : svn_authored_by?(svn_committers, people)
  end

  def svn_authored_by?(svn_committers, people)
    authored_by = false
    if (!svn_committers.empty?)
      authored_by = people.all? { |person|
        id = svn_committers[person]
        id != nil && !(/#{id}/i =~ line).nil?
      }
    end
    return authored_by
  end

  def git_authored_by?(people)
    return people.empty? ? false : people.all? { |person|
      /(^|\s+|\W)#{person}(\s+|$|\W)/i =~ line
    }
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

  def card_number card_prefix
    card_num = card_name(card_prefix)
    card_num ? card_num.gsub(card_prefix, "") : nil
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
