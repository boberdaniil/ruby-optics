module FnOrBlock
  private

  def retrieve_function_from_arg_or_block(fn, blk)
    if fn && blk
      ArgumentError.new('Can not accept both block or lambda')
    end

    return blk if blk
    
    if fn
      raise ArgumentError.new('Function must respond to #call method') unless fn.respond_to?(:call)

      return fn
    end

    raise ArgumentError.new('Either funtion or block should be provided')
  end
end