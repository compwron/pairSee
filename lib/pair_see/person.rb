module PairSee
  class Person

    attr_reader :display_name
    attr_reader :names

    def initialize(names)
      @names = names
      @display_name = names.first
    end

    def to_s
      display_name
    end
  end
end
