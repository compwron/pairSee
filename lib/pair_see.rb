class PairSee
  require 'yamler'
  require 'time'

  attr_reader :log_lines, :devs, :dev_pairs, :never

  
  
  def initialize git_home, config_file, date_string
    git_home = git_home
    @log_lines = `git --git-dir=#{git_home}/.git log --pretty=format:'%ai %s' --since=#{date_string}`.split("\n").map {|line| LogLine.new line }
    @devs = active_devs(config_file)
    @dev_pairs = devs.combination(2)
    @never = Time.parse("1970-1-1")
   end

  def active_devs config_file
    config = YAML.load_file(config_file)
    devs_in_config = config['names'].split(" ")
    devs_in_config.select { |dev| is_active(dev) }
  end

  def is_active dev
    log_lines.map { |log_line|
      log_line.authored_by?(dev) 
    }.include?(true)
  end

  def pair_commits
    dev_pairs.map { |person1, person2| 
      Combo.new(commits_for_pair(person1, person2).count, person1, person2)
    }
  end

  def solo_commits  
    devs.map { |dev| 
      commits_by_only = log_lines.select { |log_line|
        log_line.authored_by?(dev) && (devs - [dev]).none? { |d| log_line.authored_by?(d)}
      }.count
      Combo.new(commits_by_only, dev)
    }
  end

  def all_commits
    (pair_commits + solo_commits).sort_by { |combo| 
      combo.count
    }.reject(&:empty?).map(&:to_s)
  end

  def commits_for_pair person1, person2
    log_lines.select { |log_line|
      log_line.authored_by?(person1, person2)
    }
  end

  def commits_not_by_known_pair 
    log_lines.reject { |log_line| log_line.not_by_pair? devs }
  end

  def most_recent_commit_date person1, person2
    most_recent_commits = commits_for_pair(person1, person2).sort_by { |log_line| 
      log_line.date
    }
    most_recent_commits.empty? ? never : most_recent_commits.first.date
  end

  def all_most_recent_commits
    dev_pairs.map { |person1, person2|
      DateCombo.new(most_recent_commit_date(person1, person2), person1, person2)
    }.sort_by { |date_combo|
      date_combo.date 
    }.reverse.map { |date_combo| 
      date_combo.to_s
    }
  end

  def recommended_pairings
    # bonus points: if all devs have paired, recommend least recent pairing. 
    should_pair = unpaired_in_range
    should_pair.empty? ? least_recent_pair : should_pair
  end

  def least_recent_pair
    devs.select {|dev| 
      log_lines.last.line.match(dev)
    }.join(", ")
  end

  def unpaired_in_range
    dev_pairs.reject { |person1, person2| 
      most_recent_commit_date(person1, person2) - never > 0 # this is a hack, replace with .before when you get internet access
    }.map { |person1, person2| 
      "#{person1}, #{person2}"
    }
  end

  class LogLine
    attr_reader :line

    def initialize line
      @line = line 
    end

    def authored_by? *people
      people.all? { |person| /#{person}/i =~ line }
    end

    def merge_commit?
      line.match("Merge remote-tracking branch") || line.match("Merge branch")
    end

    def date
      Time.parse(line.split(" ")[0])
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
    attr_reader :date, :devs, :never

    def initialize date, *devs
      @date, @devs = date, devs
      @never = Time.parse("1970-1-1")
    end

    def to_s
      pretty_date = "#{date.year}-#{date.strftime("%m")}-#{date.strftime("%d")}"
      date == never ? "#{devs.join ", "}: not yet" : "#{devs.join ", "}: #{pretty_date}"
    end

    def empty?
      count == 0
    end
  end

end


