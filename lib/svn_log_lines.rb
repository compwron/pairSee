class SvnLogLines
  include Enumerable

  def initialize(log_location, after_date, config)
    @lines = lines_from(log_location)
    @config = config
    @committers = committer_mappings(config)
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
        lines << LogLine.new(line)
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

  private
  attr_reader :lines
end