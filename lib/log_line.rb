require 'time'
class LogLine
  attr_reader :line

  def initialize line
    @line = line
  end

  def authored_by? *people
    people.all? { |person| /#{person}/i =~ line }
  end

  def contains_card? card_prefix
    line.match(card_prefix)
  end

  def contains_card_name? card_name
    regex = /#{card_name}[\]\s]/
    matcher = line.match(regex)
    ! matcher.nil?
  end

  def card_name card_prefix
    regex = /(#{card_prefix}-\d+)/
    matcher = line.match(regex)
    matcher.nil? ? nil : (line.match regex)[1]
  end

  def merge_commit?
    line.match("Merge remote-tracking branch") || line.match("Merge branch")
  end

  def date
    Date.parse(line.split(" ")[0])
  end

  def not_by_pair? devs
    devs.any? { |dev| authored_by?(dev) || merge_commit? }
  end

  def to_s
    line
  end
end
