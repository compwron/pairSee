class PairSee
  require 'yamler'
  require 'time'

  attr_reader :log_lines, :devs
  
  def initialize git_home, config_file, date_string
    config = YAML.load_file(config_file)
    git_home = git_home
    @devs = config['names'].split(" ")
    @log_lines = `git --git-dir=#{git_home}/.git log --pretty=format:'%s' --since=#{date_string}`.split("\n").map {|line| LogLine.new line }
  end

  def pair_commits
    devs.combination(2).map { |person1, person2| 
      Combo.new(commits_for_pair(person1, person2), person1, person2)
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
    }.count
  end

  def commits_not_by_known_pair 
    log_lines.reject { |log_line| log_line.not_by_pair? devs }
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

end


