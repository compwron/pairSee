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
       mappings.merge!({pair.first => pair.last})
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

  def authored_by? *people
    name_in_line = people.all? { |person| /#{person}/i =~ line }
    if (name_in_line)
      return true
    end
    people.all? {|person| @committers[person] != nil}
  end
end