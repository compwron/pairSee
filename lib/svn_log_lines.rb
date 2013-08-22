class SvnLogLines
  attr_reader :lines

  def initialize(log_location, after_date, config)
    @lines = lines_from(log_location)
    @committers = committer_mappings(config)
  end

  def committer_mappings(config)
    config = YAML.load_file(config)
    mappings = {}
    config['committers'].split(",").map {|pairing|
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


end