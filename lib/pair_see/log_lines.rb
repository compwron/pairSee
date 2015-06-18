require 'pry'
module PairSee
  class LogLines
    require_relative 'log_line'
    require 'git'
 
    include Enumerable

    def initialize(git_home, date_string)
      @lines = _lines_from(git_home, date_string)
    end

    def _lines_from(git_home, date_string)
      g = Git.open(git_home)
      puts 'getting commits'
      a = g.log(1000000).since(date_string).map do |commit|
        LogLine.new(commit)
      end
      puts 'got commits'
      a
    end

    def each(&block)
      @lines.each &block
    end

    def last
      @lines.last
    end

    def active?(dev)
      any? do |log_line|
        log_line.authored_by?(dev)
      end
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
