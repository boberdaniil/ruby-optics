# frozen_string_literal: true

require_relative 'nullable'

class Lens
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

  def each_lens
    Each.new(outer_focus = self)
  end

  def self.identity
    @_identity ||= Lens.new(
      -> (obj) { obj },
      -> (new_val, _obj) { new_val }
    )
  end
end