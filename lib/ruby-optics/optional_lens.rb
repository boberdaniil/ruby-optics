class OptionalLens
  attr_reader :getter
  attr_reader :setter

  def initialize(getter, setter)
    @getter = getter
    @setter = setter
  end

  def get(obj)
    result = getter.(obj)
    if result.nil?
      None
    else
      Maybe(result).flatten
    end
  end

  def modify(obj, &blk)
    getter.(obj).fmap { |value|
      setter.(
        blk.(value),
        obj
      ).value_or(obj)
    }
  end

  def compose_lens(other_lense)
    Lens.new(
      -> (obj) { getter.(obj).fmap { |val| other_lense.getter.(val) } },
      -> (new_val, obj) {
        getter.(obj).fmap { |val|
          setter.(
            other_lense.setter.(
              new_val,
              val
            ),
            obj
          )
        }
      }
    )
  end
end