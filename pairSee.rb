class PairSee
  require 'yamler'
    
  def initialize(config_file)
    config = YAML.load_file(config_file)
    git_home = config['root']
    @devs = config['names'].split(" ")
    @git_log = `git --git-dir=#{git_home}/.git log --pretty=format:'%s'`.split("\n")
  end

  def commits_for_pair(person1, person2) 
    @git_log.map { |log_line|
      log_line.match(person1) && log_line.match(person2) ? 1 : 0
    }.reduce(:+)
  end

  def commits_by_only(person)
    @git_log.map { |log_line|
      log_line.match(person) && @devs.map { |dev| !log_line.match(dev) }
    }
  end

  def pair_commits_list
    @devs.combination(2).map { |person1, person2| 
      [[person1, person2], commits_for_pair(person1, person2)]
    }.sort {|combo| 
        combo.last
      }.map { |combo|
        "#{combo.first.first}, #{combo.first.last}: #{combo.last}"
      }
  end
end
