# This is from Draper
# specifically here: https://github.com/drapergem/draper/commit/4b933ef39d252ecfe93c573a072633be545c49fb#lib/draper/collection_decorator.rb
# Tweaked slightly
# * you must provide the with: option (decorator_class is required)
# * you must provide the context: option (view context is required)
# * removed some methods we don't need because we're not Draper
# * delegate Kaminari::PaginatableArray methods as well, to the object not decorated collection
# * use our delegate_instance_methods_of helper
module Whitehall
  module Decorators
    class CollectionDecorator
      include Enumerable

      # @return [Class] the decorator class used to decorate each item, as set by
      #   {#initialize}.
      attr_reader :decorator_class

      # @return [Hash] extra data to be used in user-defined methods, and passed
      #   to each item's decorator.
      attr_accessor :context

      extend DelegateInstanceMethodsOf
      delegate_instance_methods_of Array,
                                   to: :decorated_collection,
                                   with_extra_methods: :==
      delegate_instance_methods_of Kaminari::PaginatableArray,
                                   Kaminari::PageScopeMethods,
                                   to: :object,
                                   without_methods_of: Array,
                                   with_default_methods: false

      # @param [Enumerable] object
      #   collection to decorate.
      # @param [Class] decorator_class
      #   the decorator class used to decorate each item. When `nil`, each item's
      #   {Decoratable#decorate decorate} method will be used.
      # @param [Object] context
      #   extra data to be stored in the collection decorator and used in
      #   user-defined methods, and passed to each item's decorator.
      def initialize(object, decorator_class, context)
        @object = object
        @decorator_class = decorator_class
        @context = context
      end

      # @return [Array] the decorated items.
      def decorated_collection
        @decorated_collection ||= object.map { |item| decorate_item(item) }
      end

      # Delegated to the decorated collection when using the block form
      # (`Enumerable#find`) or to the decorator class if not
      # (`ActiveRecord::FinderMethods#find`)
      def find(*args, &block)
        if block_given?
          decorated_collection.find(*args, &block)
        else
          ActiveSupport::Deprecation.warn("Using ActiveRecord's `find` on a CollectionDecorator is deprecated. Call `find` on a model, and then decorate the result", caller)
          decorate_item(object.find(*args))
        end
      end

      def to_s
        "#<#{self.class.name} of #{decorator_class} for #{object.inspect}>"
      end

      def kind_of?(klass)
        decorated_collection.kind_of?(klass) || super
      end
      alias_method :is_a?, :kind_of?

      def replace(other)
        decorated_collection.replace(other)
        self
      end

      # @return the collection being decorated.
      attr_reader :object

      # Decorates the given item.
      def decorate_item(item)
        decorator_class.new(item, context)
      end

      def ==(other)
        if other.respond_to? :object
          @object == other.object
        else
          @object == other
        end
      end
    end
  end
end
