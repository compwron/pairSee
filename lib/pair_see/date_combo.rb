module PairSee
  class DateCombo
    attr_reader :date, :devs

    def initialize(date, *devs)
      @date, @devs = date, devs
    end

    def to_s
      if date.nil?
        "#{devs.join ', '}: not yet"
      else
        "#{devs.join ', '}: #{date}"
      end
    end

    def <=>(other)
      if date && other.date
        date <=> other.date
      elsif date
        1
      elsif other.date
        -1
      else
        0
      end
    end
  end
end
