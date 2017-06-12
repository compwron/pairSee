module PairSee
  class LogLines
    require_relative 'log_line'
    require 'git'

    include Enumerable

    def initialize(lines)
      @lines = lines
    end

    def each(&block)
      lines.each &block
    end

    def last
      lines.last
    end

    def active?(person)
      any? do |log_line|
        log_line.authored_by?(person)
      end
    end

    def commits_for_pair(person1, person2)
      select {|log_line| log_line.authored_by?(person1, person2)}
    end

    def commits_not_by_known_pair(devs)
      reject {|log_line| log_line.by_any? devs}
    end

    def solo_commits(people, person)
      select do |log_line|
        log_line.authored_by?(person) && (people - [person]).none? {|single_person| log_line.authored_by?(single_person)}
      end
    end

    private

    attr_reader :lines
  end
end
