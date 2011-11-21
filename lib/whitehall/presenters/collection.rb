module Whitehall
  module Presenters
    class Collection
      include Enumerable

      def initialize(collection)
        @collection = collection
      end

      class_attribute :object_presenter_class
      def self.present_object_with(&block)
        self.object_presenter_class = Class.new(Whitehall::Presenters::Object, &block)
      end

      def each
        @collection.each do |obj|
          if self.class.object_presenter_class?
            yield self.class.object_presenter_class.new(obj)
          else
            yield obj
          end
        end
      end
    end
  end
end