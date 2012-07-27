class PairSee
  require 'yamler'
  require 'time'

  attr_reader :git_log, :devs
  
  def initialize git_home, config_file, date_string
    config = YAML.load_file(config_file)
    git_home = git_home
    @devs = config['names'].split(" ") # todo: yaml array
    @git_log = `git --git-dir=#{git_home}/.git log --pretty=format:'%s' --since=#{date_string}`.split("\n")
  end

  def pair_commits
    devs.combination(2).map { |person1, person2| 
      Combo.new(commits_for_pair(person1, person2), person1, person2)
    }
  end

  def solo_commits 
    devs.map { |dev| 
      commits_by_only = git_log.select { |log_line|
        logContainsDev(log_line, dev) && does_not_match_other_devs(log_line, dev)
      }.count
      Combo.new(commits_by_only, dev)
    }
  end

  def all_commits
    (pair_commits + solo_commits).sort_by() { |combo| 
      combo.count
      }.reject(&:empty?).map(&:to_s)
  end

  def commits_for_pair person1, person2
    git_log.select { |log_line|
      logContainsDev(log_line, person1) && logContainsDev(log_line, person2)
    }.count
  end

  def logContainsDev log_line, person
    /#{person}/i =~ log_line
  end

  def does_not_match_other_devs log_line, person
    devs.reject { |dev| 
      dev == person}.none? { |dev| logContainsDev(log_line, dev) 
    }
  end

  def commits_not_by_known_pair 
    # todo: do this better.
    git_log.reject {|log_line|
      drop_line = false
      devs.each { |dev|
        drop_line = true if logContainsDev(log_line, dev)
      }
      drop_line
    }
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


