module Whitehall
  module Decorators
    class Decorator < Struct.new(:model, :context)
      def self.delegate_instance_methods_of(*model_classes)
        delegate_options = { to: :model }
        delegate_options.merge(model_classes.pop) if model_classes.last.is_a? Hash
        # make sure each AR class is fully realised with methods for
        # their db attributes
        model_classes.each { |mc| mc.define_attribute_methods if mc.respond_to?(:define_attribute_methods) }

        methods = model_classes.map { |mc| mc.instance_methods }.flatten.uniq
        methods -= Object.instance_methods

        delegate *methods, delegate_options
      end
    end
  end
end
