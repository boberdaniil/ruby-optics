class Const
  attr_reader :get_const

  def initialize(get_const)
    @get_const = get_const
  end

  def map(&blk)
    self
  end

  def zip(another)
    Const.new([get_const, another.get_const])
  end
end