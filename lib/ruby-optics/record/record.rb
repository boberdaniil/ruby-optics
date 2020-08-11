# frozen_string_literal: true

require_relative 'record_lens'

module Record
  def initialize(args_hash)
    defined_attributes = self.class.instance_variable_get(
      :"@_record_attributes_defs"
    ) || []

    missing_attributes = []

    defined_attributes.each do |defined_attribute_params|
      attribute_name = defined_attribute_params[:attribute_name]
      attribute_argument = args_hash[attribute_name]
      if attribute_argument.nil?
        default_value = defined_attribute_params[:default]
        if defined_attribute_params[:nullable] || default_value
          instance_variable_set(
            :"@#{attribute_name}",
            default_value
          )
        else
          missing_attributes << attribute_name
        end
      else
        instance_variable_set(
          :"@#{attribute_name}",
          attribute_argument
        )
      end
    end

    missing_attributes.uniq!
    if missing_attributes.any?
      missing_attributes_str = missing_attributes.map { |a| "'#{a}'"}.join(', ')
      error_message = "Missing #{missing_attributes.length == 1 ? 'attribute' : 'attributes' } #{missing_attributes_str}"

      raise ArgumentError.new(error_message)
    end
  end

  def copy_with(args_hash)
    self.class.new(
      _current_attributes.merge(
        args_hash.reject { |k, v| !_current_attributes.keys.include?(k) }
      )
    )
  end

  def ==(another_record)
    return false unless another_record.is_a?(self.class)
  
    another_record_attributes = another_record.send(:_current_attributes)

    _current_attributes == another_record_attributes
  end

  alias_method :eql?, :==

  def hash
    [self.class, _current_attributes].hash
  end

  if RUBY_VERSION.to_f >= 2.7
    def deconstruct_keys(keys)
      _current_attributes
    end
  end

  def self.included(base)
    base.define_singleton_method(:attribute) do |attribute_name, nullable: false, default: nil|
      @_record_attributes_defs ||= []
      @_record_attributes_defs << {
        attribute_name: attribute_name,
        nullable:       nullable,
        default:        default
      }

      base.send(:attr_reader, attribute_name)
    end

    base.instance_variable_set(:"@_lenses", {})

    base.define_singleton_method(:lens) do |*attribute_names|
      head, *tail = attribute_names
      fst_lens = (@_lenses[head] ||= RecordLens.build(head))

      return fst_lens if tail.empty?

      [fst_lens, *tail].reduce { |result_lens, attribute_name|
        result_lens.compose_lens(RecordLens.build(attribute_name))
      }
    end
  end

  private

  def _current_attributes
    defined_attributes = self.class.instance_variable_get(
      :"@_record_attributes_defs"
    ) || []

    defined_attributes
      .map { |attribute_params| attribute_params[:attribute_name] }
      .map { |attr_name| [attr_name, instance_variable_get(:"@#{attr_name}")] }
      .to_h
  end
end