module Whitehall
  module Decorators
    class Decorator
      extend DelegateInstanceMethodsOf

      attr_accessor :model, :context

      def initialize(model, context = nil)
        @model = model
        @context = context
      end

      def ==(other)
        if other.respond_to? :model
          model == other.model
        elsif other.respond_to? :to_model
          model == other.to_model
        else
          model == other
        end
      end
    end
  end
end
