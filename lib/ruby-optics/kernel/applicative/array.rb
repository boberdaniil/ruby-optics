require_relative '../../utils/fn_or_block'

module Applicative
  module ArrayInstance
    def self.pure(a)
      [a]
    end

    def map(array, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
      array.map(&fn)
    end

    def map2(array1, array2, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
    end
  end
end