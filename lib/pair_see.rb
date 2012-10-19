class PairSee
  require 'yamler'
  require 'time'

  attr_reader :log_lines, :devs, :dev_pairs

  def initialize git_home, config_file, date_string
    @log_lines = LogLines.new git_home, date_string
    @devs = active_devs(config_file)
    @dev_pairs = devs.combination(2)
   end

   def pretty_card_data card_prefix
    card_data(card_prefix).map {|card_datum| 
      "#{card_datum.keys.first} #{card_datum.values.first}"
    }
   end

   def card_data card_prefix
    card_numbers(card_prefix).map { |card_number|
      { card_number => commits_on_card(card_number) }
    }
   end

   def commits_on_card card_name
    log_lines.select{|line| line.contains_card_name?(card_name)}.count
   end

   def cards_worked card_prefix
    log_lines.select{|line| line.contains_card?(card_prefix) }.count
   end

   def card_numbers card_prefix
    log_lines.select { |line| 
      line.contains_card?(card_prefix) 
    }.map { |line|
      line.card_number(card_prefix)
    }.uniq.compact
   end

  def active_devs config_file
    config = YAML.load_file(config_file)
    devs_in_config = config['names'].split(" ")
    devs_in_config.select { |dev| is_active(dev) }
  end

  def is_active dev
    log_lines.active? dev
  end

  def pair_commits
    dev_pairs.map { |person1, person2| 
      Combo.new(commits_for_pair(person1, person2).count, person1, person2)
    }
  end

  def solo_commits  
    devs.map { |dev|
      Combo.new(log_lines.solo_commits(devs, dev).count, dev)
    }
  end

  def all_commits
    (pair_commits + solo_commits).sort_by(&:count).reject(&:empty?).map(&:to_s)
  end

  def commits_for_pair person1, person2
    log_lines.commits_for_pair person1, person2
  end

  def commits_not_by_known_pair 
    log_lines.commits_not_by_known_pair devs
  end

  def most_recent_commit_date person1, person2
    recent_commit = commits_for_pair(person1, person2).sort_by(&:date).first
    recent_commit ? recent_commit.date : nil
  end

  def all_most_recent_commits
    dev_pairs.map { |person1, person2|
      DateCombo.new(most_recent_commit_date(person1, person2), person1, person2)
    }.sort.reverse.map &:to_s
  end

  def recommended_pairings
    should_pair = unpaired_in_range
    should_pair.empty? ? least_recent_pair : should_pair
  end

  def least_recent_pair
    devs.select {|dev| 
      log_lines.last.line.match(dev)
    }.join(", ")
  end

  def unpaired_in_range
    dev_pairs.select { |person1, person2|
      most_recent_commit_date(person1, person2).nil?
    }.map { |person1, person2| 
      "#{person1}, #{person2}"
    }
  end

  class LogLines
    include Enumerable

    def initialize git_home, date_string
      @lines = `git --git-dir=#{git_home}/.git log --pretty=format:'%ai %s' --since=#{date_string}`.split("\n").map {|line| 
        LogLine.new line 
      }
    end

    def each &block
      lines.each &block
    end

    def last
      lines.last
    end

    def active? dev
      any? { |log_line| log_line.authored_by?(dev) }
    end

    def commits_for_pair person1, person2
      select { |log_line| log_line.authored_by?(person1, person2) }
    end

    def commits_not_by_known_pair devs
      reject { |log_line| log_line.not_by_pair? devs }
    end

    def solo_commits devs, dev
      select { |log_line|
        log_line.authored_by?(dev) && (devs - [dev]).none? { |d| log_line.authored_by?(d)}
      }
    end

    private
      attr_reader :lines
  end

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
      line.match(card_name)
    end

    def card_number card_prefix
      regex = /#{card_prefix}-(\d+)/
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

  class Combo
    attr_reader :count, :devs

    def initialize count, *devs
      @count, @devs = count, devs
    end

    def to_s
      "#{devs.join ", "}: #{count}"
    end

    def empty?
      count == 0
    end
  end

  class DateCombo
    attr_reader :date, :devs

    def initialize date, *devs
      @date, @devs = date, devs
    end

    def to_s
      if date.nil?
        "#{devs.join ", "}: not yet"
      else
        "#{devs.join ", "}: #{date.to_s}"
      end
    end

    def <=> other
      if date && other.date
        date <=> other.date
      elsif date
        1
      elsif other.date
        -1
      else
        0
      end
    end
  end
end
