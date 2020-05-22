require_relative 'utils/fn_or_block'
require_relative 'utils/id_functor_delegator'
require_relative 'utils/const'
require_relative 'kernel/applicative'

class Traversal
  include FnOrBlock

  def initialize(fn = nil, &blk)
    @modify_f = retrieve_function_from_arg_or_block(fn, blk)
  end

  def modify_f(obj, fn = nil, &blk)
    functor_modify_fn = retrieve_function_from_arg_or_block(fn, blk)

    @modify_f.(obj, functor_modify_fn)
  end

  def modify(obj, fn = nil, &blk)
    modify_fn0 = retrieve_function_from_arg_or_block(fn, blk)
    modify_fn1 = -> (obj) { IdFunctorDelegator.new(modify_fn0.(obj)) }

    modify_f(obj, modify_fn1)
  end

  def get_all(obj)
    modify_f(obj, -> (val) { Const.new([val]) }).get_const
  end

  def compose_lens(lens)
    compose_traversal(lens.to_traversal)
  end

  def compose_traversal(other_traversal)
    Traversal.new { |obj, fn|
      modify_f(
        obj,
        -> (modified_obj) {
          other_traversal.modify_f(modified_obj, fn)
        }
      )
    }
  end

  def self.for_list
    Traversal.new { |list, fn|
      head, *tail = list
      head_result = fn.(head)

      applicative = Applicative.instance_for(head_result.class)

      tail.reduce(head_result) { |acc, a|
        result = fn.(a)
        applicative.map2 { |a, b| acc + [res] }
      }
    }
  end
end