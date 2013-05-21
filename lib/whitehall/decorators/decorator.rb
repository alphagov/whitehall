module Whitehall
  module Decorators
    class Decorator < Struct.new(:model, :context)
      extend DelegateInstanceMethodsOf

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
