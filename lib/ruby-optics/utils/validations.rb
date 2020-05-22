module Validations
  def self.check_applicative(obj)
    check_functor(obj)

    unless obj.respond_to?(:zip)
      raise StandardError.new("Result of provided function must respond to #zip")
    end
  end

  def self.check_functor(obj)
    unless obj.respond_to?(:map)
      raise StandardError.new('Provided function must return object responding to #map')
    end
  end
end