require_relative 'log_line'

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
