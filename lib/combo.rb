class Combo
  attr_reader :count, :devs

  def initialize(count, *devs)
    @count, @devs = count, devs
  end

  def to_s
    "#{devs.join ', '}: #{count}"
  end

  def empty?
    count == 0
  end
end
