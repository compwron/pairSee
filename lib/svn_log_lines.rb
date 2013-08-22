class SvnLogLines
  attr_reader :lines

  def initialize(log_location, after_date)
    @lines = lines_from(log_location)

  end

  def lines_from log_location
    lines = []
    File.open(log_location) do |infile|
      while (line = infile.gets)
        lines << line
      end
    end
    lines
  end
end