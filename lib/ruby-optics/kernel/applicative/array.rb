require_relative '../../utils/fn_or_block'

module Applicative
  module ArrayInstance
    extend FnOrBlock

    def self.pure(a)
      [a]
    end

    def self.map(array, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
      array.map(&fn)
    end

    def self.map2(array1, array2, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
      array1.flat_map { |a1| array2.map { |a2| fn.(a1, a2) } }
    end
  end
end