module PairSee
  class LogLines
    require_relative 'log_line'
    require 'git'

    include Enumerable

    def initialize(git_home, date_string)
      @commits = Git.open(git_home).log(1000000).since(date_string)
    end

    def lines
      @lines_from ||= @commits.map {|c| LogLine.new(c)}
    end

    def devs
      @dev_names ||= @commits.map {|c| c.author.name.gsub(' ', '') }.uniq
    end

    def each(&block)
      lines.each &block
    end

    def last
      lines.last
    end

    def commits_for_pair(person1, person2)
      select { |log_line| log_line.authored_by?(person1, person2) }
    end

    def commits_not_by_known_pair(devs)
      reject { |log_line| log_line.not_by_pair? devs }
    end

    def solo_commits(devs, dev)
      select do |log_line|
        log_line.authored_by?(dev) && (devs - [dev]).none? { |d| log_line.authored_by?(d) }
      end
    end
  end
end
