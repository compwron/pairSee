module PairSee
  class LogLineParse
    require_relative 'log_lines'
    require 'git'

    @@maximum_commits_to_parse = 9999
    attr_reader :log_lines

    def initialize(roots, date_string)
      @log_lines = _parse(date_string, roots)
    end

    def _parse(date_string, roots)
      lines = []
      roots.each do |root|
        g = Git.open(root)
        lines << g.log(@@maximum_commits_to_parse).since(date_string).map do |l|
          LogLine.new("#{l.date} #{l.message}")
        end
      end
      LogLines.new(lines.flatten)
    end
  end
end