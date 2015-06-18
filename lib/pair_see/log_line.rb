module PairSee
  class LogLine
    require 'time'

    def initialize(commit)
      @message = commit.message
      @branch_history = _card_name_message(commit)
      @date = commit.date
      @author = commit.author.name
    end

    def authored_by?(*people)
      # binding.pry
      a = people.empty? ? false : people.all? do |person|
        @author.include?(person)
      end
    end

    def contains_card?(card_prefix)
      message.match(card_prefix) || @branch_history.match(card_prefix)
    end

    def contains_card_name?(card_name)
      _card_matchers.any? {|cm| !cm.nil? }
    end

    def _card_matchers(card_name)
      git_regex = /#{card_name}[\]\s\[,:]/
      message_matcher = @message.match(git_regex)
      branch_history_matcher = @branch_history.match(git_regex)
      [message_matcher, branch_history_matcher]
    end

    def card_name(card_prefix)
      regex = /(#{card_prefix}\d+)/
      message_matcher = @message.match(regex)
      branch_history_matcher = @branch_history.match(regex)
      return @message.match(regex)[1] unless message_matcher.nil?
      return @branch_history.match(regex)[1] unless branch_history_matcher.nil?
    end

    def card_number(card_prefix)
      card_num = card_name(card_prefix)
      card_num ? card_num.gsub(card_prefix, '') : nil
    end

    def merge_commit?
      message.match('Merge remote-tracking branch') || @message.match('Merge branch')
    end

    def not_by_pair?(devs)
      devs.any? { |dev| authored_by?(dev) || merge_commit? }
    end

    def to_s
      line
    end

    def _card_name_message(commit)
      branch_history = commit.name
      branch_history += ' ' + commit.parent.name if commit.parent.name 
      branch_history += ' ' + commit.parent.parent.name if commit.parent.parent
      branch_history + ' ' + commit.message
    end
  end
end
