require_relative '../../utils/fn_or_block'
require_relative '../../utils/const'

module Applicative
  module ConstInstance
    extend FnOrBlock

    def self.pure(a)
      Const.new(a)
    end

    def self.map(const, fn = nil, &blk)
      fn = retrieve_function_from_arg_or_block(fn, blk)
      const.map(&fn)
    end

    def self.map2(const1, const2, fn = nil, &blk)
      a1 = const1.get_const
      a2 = const2.get_const

      Const.new(a1 + a2)
    end
  end
end