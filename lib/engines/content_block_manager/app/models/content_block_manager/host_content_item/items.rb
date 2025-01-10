module ContentBlockManager
  class HostContentItem
    class Items < Data.define(:items, :total, :total_pages, :rollup)
      extend Forwardable

      ARRAY_METHODS = ([].methods - Object.methods)
      Rollup = Data.define(:views, :locations, :instances, :organisations)

      def_delegators :items, *ARRAY_METHODS
    end
  end
end
