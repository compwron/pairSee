module PairSee
  class LogLines
    require_relative 'log_line'
    require 'git'

    include Enumerable

    def initialize(git_home, date_string)
      puts "getting commits"
      @commits = Git.open(git_home).log(1000000).since(date_string)
      puts "got commits"
    end

    def lines
      puts "turning #{@commits.count} commits into lines"
      @lines_from ||= @commits.each_with_index.map do |c, index| 
        puts "#{Time.now} converting line #{index}" if index % 10 == 0
        LogLine.new(c)
      end
      puts "done turning commits into lines"
      @lines_from
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
