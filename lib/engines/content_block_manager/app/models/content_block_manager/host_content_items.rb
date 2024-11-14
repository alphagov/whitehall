module ContentBlockManager
  class HostContentItems < Data.define(:items, :total, :total_pages)
    extend Forwardable

    ARRAY_METHODS = ([].methods - Object.methods)

    def_delegators :items, *ARRAY_METHODS
  end
end
