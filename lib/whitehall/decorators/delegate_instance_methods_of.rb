module Whitehall
  module Decorators
    module DelegateInstanceMethodsOf
      # methods added by rails to object that we probably do want to
      # delegate  .. shame these aren't collected somewhere that makes
      # them easy to detect
      DEFAULT_METHODS_TO_ALWAYS_DELEGATE = [
        :to_param, :to_query, :try, :with_options, :as_json,
        :instance_values, :instance_variable_names, :in?,
        :duplicable?, :nil?, :blank?, :present?, :presence
      ].freeze

      # delegate instance methods of a set of classes
      # options:
      #   to: name of thing to delegate to (default :model)
      #   without_methods_of: array of classes whose instance methods to
      #                       remove from delegation (default: [Object])
      #   with_default_methods: true/false on whether or not to delegate
      #                         the DEFAULT_METHODS_TO_ALWAYS_DELEGATE
      #                         anyway (even if without_methods_of would
      #                         have removed them) (default: true)
      #   with_extra_methods: array of other methods to delegate
      #                       that are not present in the instance_methods
      #                       from the provided classes (default: [])
      def delegate_instance_methods_of(*model_classes)
        delegate_options = {
          to: :model,
          without_methods_of: Object,
          with_default_methods: true,
          with_extra_methods: []
        }
        delegate_options = delegate_options.merge(model_classes.pop) if model_classes.last.is_a? Hash
        # make sure each AR class is fully realised with methods for
        # their db attributes
        model_classes.each do |model_class|
          if model_class.respond_to?(:define_attribute_methods)
            model_class.define_attribute_methods
          end
        end

        methods = model_classes.map { |mc| mc.instance_methods }.flatten.uniq
        without_methods_of = delegate_options.delete(:without_methods_of)
        Array.wrap(without_methods_of).each { |without| methods -= without.instance_methods }
        methods += DEFAULT_METHODS_TO_ALWAYS_DELEGATE if delegate_options.delete(:with_default_methods)
        methods += Array.wrap(delegate_options.delete(:with_extra_methods))

        delegate *methods, delegate_options
      end
    end
  end
end
