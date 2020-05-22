require_relative 'nullable'
require_relative 'traversal'
require_relative 'utils/fn_or_block'
require_relative 'kernel/functor'

class Lens
  include FnOrBlock

  attr_reader :getter
  attr_reader :setter

  include NullableOptic

  def initialize(getter, setter)
    @getter = getter
    @setter = setter
  end

  def get(obj)
    getter.(obj)
  end

  def set(new_val, obj)
    setter.(new_val, obj)
  end

  def modify(obj, &blk)
    setter.(
      blk.(getter.(obj)),
      obj
    )
  end

  def modify_f(object, fn = nil, &blk)
    functor_modify_fn = retrieve_function_from_arg_or_block(fn, blk)

    functor_result = functor_modify_fn.(get(object))
    Functor.has_functor_instance?(functor_result)

    functor_result.map { |a| set(a, object) }
  end

  def compose_lens(other_lense)
    Lens.new(
      -> (obj) { other_lense.getter.(getter.(obj)) },
      -> (new_val, obj) {
        setter.(
          other_lense.setter.(
            new_val,
            getter.(obj)
          ),
          obj
        )
      }
    )
  end

  def compose_traversal(other_traversal)
    self
      .as_traversal
      .compose_traversal(other_traversal)
  end

  def to_traversal
    Traversal.new { |obj, fn|
      self.modify_f(obj, fn)
    }
  end
end