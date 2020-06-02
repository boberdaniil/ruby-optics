# frozen_string_literal: true

class Each
  attr_reader :inner_focus
  attr_reader :outer_focus
  attr_reader :filter

  Filter = Struct.new(:focus, :blk)

  def initialize(outer_focus = nil, inner_focus = nil, filter = nil)
    @outer_focus = outer_focus || Lens.identity
    @inner_focus = inner_focus || Lens.identity
    @filter = filter
  end

  def set(new_value, object)
    modify_all(object) { |_| new_value }
  end

  def modify_all(object, &blk)
    outer_focus.modify(object) { |enumerable|
      filtered(enumerable).map { |a| inner_focus.modify(a, &blk) }
    }
  end

  def get_all(object)
    filtered(outer_focus.get(object)).map { |a| inner_focus.get(a) }
  end

  def with_filter(filtering_focus, &blk)
    Each.new(
      outer_focus = self.outer_focus,
      inner_focus = self.inner_focus,
      filter      = Filter.new(filtering_focus, blk)
    )
  end

  def compose_lens(lens)
    Each.new(
      outer_focus = self.outer_focus,
      inner_focus = self.inner_focus.compose_lens(lens),
      filter      = self.filter
    )
  end

  private
  
  def filtered(enumerable)
    return enumerable if filter.nil? 

    enumerable.select { |element| filter.blk.(filter.focus.get(element)) }
  end
end
