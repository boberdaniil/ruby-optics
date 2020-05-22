class IdFunctorDelegator
  def initialize(object)
    @object = object
  end

  def map(&blk)
    return self if blk.nil?

    blk.(@object)
  end
end