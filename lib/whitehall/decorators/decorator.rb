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
        model == if other.respond_to? :model
                   other.model
                 elsif other.respond_to? :to_model
                   other.to_model
                 else
                   other
                 end
      end
    end
  end
end
