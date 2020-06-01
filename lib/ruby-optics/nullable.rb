# frozen_string_literal: true

module NullableOptic
  def nullable
    self.class.new(
      -> (obj) {
        if obj.nil?
          nil
        else
          getter.(obj)
        end
      },

      -> (new_val, obj) {
        if obj.nil?
          nil
        else
          setter.(new_val, obj)
        end
      }
    )
  end
end