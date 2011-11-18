module Whitehall
  module Presenters
    class Collection
      include Enumerable

      def initialize(collection)
        @collection = collection
      end

      cattr_accessor :object_presenter_class
      def self.present_object_with(&block)
        self.object_presenter_class = Class.new(Whitehall::Presenters::Object, &block)
      end

      def each
        @collection.each { |p| yield self.class.object_presenter_class.new(p) }
      end
    end
  end
end