# frozen_string_literal: true

module RecordLens
  def self.build(attribute_name)
    Lens.new(
      -> (record) { record.send(attribute_name) },
      -> (new_attr_value, record) {
        record.copy_with(attribute_name => new_attr_value)
      }
    )
  end
end