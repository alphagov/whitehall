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
        # methods added by rails to object that we probably do want to
        # delegate  .. shame these aren't collected somewhere that makes
        # them easy to detect
        methods += [:to_param, :to_query, :try, :with_options, :to_json, 
                    :instance_values, :instance_variable_names, :in?,
                    :duplicable?, :nil?, :blank?, :present?, :presence]

        delegate *methods, delegate_options
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
