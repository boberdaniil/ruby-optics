module Functor
  # TODO: make registry thread safe

  FunctorInstanceNotFound = Class.new(StandardError)

  def self.instance_for(klass)
    instance = @_registry[klass]
    if instance.nil?
      from_applicative = functor_instance_from_applicative(klass)

      if from_applicative.nil?
        raise FunctorInstanceNotFound.new(
          "Can not found applicative instance for #{klass}"
        )
      end

      register_instance(klass, from_applicative)
      from_applicative
    end
  end
  
  def self.register_instance(klass, instance)
    @registry[klass] = instance
  end
  
  private

  def self.functor_instance_from_applicative(klass)
    applicative_instance = Applicatie.instance_for(klass)

    c = Class.new do
      def map(obj, fn = nil, &blk)
        applicative_instance.map(obj, fn, &blk)
      end
    end
    
    c.new
  rescue ApplicativeInstanceNotFound
    nil
  end

  def self.populate_standard_instances!
    @_registry = {
      Array => Functor::ArrayInstance
    }
  end

  populate_standard_instances!
end