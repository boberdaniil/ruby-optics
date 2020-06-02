# frozen_string_literal: true

class Each
  attr_reader :inner_focus
  attr_reader :outer_focus
  attr_reader :filter

  Filter = Struct.new(:focus, :blk) do
    def call(object)
      blk.(focus.get(object))
    end
  end

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
      enumerable.map { |a|
        if !filter.nil?
          filter.call(a) ? inner_focus.modify(a, &blk) : a
        else
          inner_focus.modify(a, &blk)
        end
      }
    }
  end

  def get_all(object)
    filtered(outer_focus.get(object)).map { |a| inner_focus.get(a) }
  end

  def with_filter(focusing_lens, &blk)
    Each.new(
      outer_focus = self.outer_focus,
      inner_focus = self.inner_focus,
      filter      = Filter.new(focusing_lens, blk)
    )
  end

  def compose_lens(lens)
    Each.new(
      outer_focus = self.outer_focus,
      inner_focus = self.inner_focus.compose_lens(lens),
      filter      = self.filter
    )
  end

  def self.with_filter(focusing_lens, &blk)
    Each.new.with_filter(focusing_lens, &blk)
  end

  private
  
  def filtered(enumerable)
    return enumerable if filter.nil? 

    enumerable.select { |object| filter.call(object) }
  end
end
