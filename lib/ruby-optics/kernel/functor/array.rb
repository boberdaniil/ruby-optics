require_relative '../../utils/fn_or_block'

module Functor
  module ArrayInstance
    extend FnOrBlock

    def self.map(array, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
      array.map(&fn)
    end
  end
end