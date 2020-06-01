# frozen_string_literal: true

require_relative 'nullable'
require_relative 'utils/fn_or_block'

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
end