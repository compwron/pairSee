module PairSee
  class ActiveDevs
    attr_reader :devs

    def initialize(log_lines, people)
      @log_lines = log_lines
      @devs = _active(people)
    end

    def _active(devs)
      devs.select do |dev|
        _is_active?(dev)
      end
    end

    def _is_active?(dev)
      @log_lines.active? dev
    end
  end
end
