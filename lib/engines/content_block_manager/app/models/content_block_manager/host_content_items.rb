module ContentBlockManager
  class HostContentItems < Data.define(:items, :total, :total_pages, :rollup)
    extend Forwardable

    ARRAY_METHODS = ([].methods - Object.methods)

    def_delegators :items, *ARRAY_METHODS

    class Rollup < Data.define(:views, :locations, :instances, :organisations); end
  end
end
