require_relative 'log_line'

class SvnLogLines
  include Enumerable

  def initialize(log_location, after_date, config)
    @lines = except_lines_after(lines_from(log_location), after_date)
    @config = config
    @committers = committer_mappings(config)
  end

  def except_lines_after(lines, after_date)
    lines.reject{|line|
      line.date < Date.parse(after_date)
    }
  end

  def committer_mappings(config)
    config = YAML.load_file(config)
    mappings = {}
    config['committers'].split(",").map { |pairing|
      pair = pairing.split(" ")
      mappings.merge!({pair.last => pair.first})
    }
    mappings
  end

  def lines_from log_location
    lines = []
    File.open(log_location) do |infile|
      while (line = infile.gets)
        lines << LogLine.new(line) unless line.strip.empty?
      end
    end
    lines
  end

  def active? dev
    @lines.each { |line|
      if (line.authored_by?(committer_mappings(@config), dev))
        return true
      end
    }
    false
  end

  def size
    @lines.size
  end

  def each &block
    lines.each &block
  end

  def commits_for_pair person1, person2
    select { |log_line| log_line.authored_by?([], person1, person2) }
  end

  def solo_commits devs, dev
    select { |log_line|
      log_line.authored_by?(committer_mappings(@config), dev) && (devs - [dev]).none? { |d|
        log_line.authored_by?(committer_mappings(@config), d)
      }
    }
  end

  def to_s
    @lines.map { |line| line.to_s }
  end

  def commits_not_by_known_pair devs
    reject { |log_line| log_line.not_by_pair? devs, committer_mappings(@config) }
  end

  private
  attr_reader :lines
end