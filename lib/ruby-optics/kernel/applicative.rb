require_relative 'applicative/array'
require_relative 'applicative/const'

module Applicative
  # TODO: make registry thread safe

  ApplicativeInstanceNotFound = Class.new(StandardError)
  
  def self.instance_for(klass)
    instance = @_registry[klass]
    if instance.nil?
      raise ApplicativeInstanceNotFound.new(
        "Can not found applicative instance for #{klass}"
      )
    end
  end

  def self.register_instance(klass, instance)
    @registry[klass] = instance
  end

  private

  def self.populate_standard_instances!
    @_registry = {
      Array => Applicative::ArrayInstance,
      Const => Applicative::ConstInstance
    }
  end

  populate_standard_instances!
end