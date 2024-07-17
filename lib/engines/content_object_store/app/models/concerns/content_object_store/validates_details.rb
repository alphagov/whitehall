module ContentObjectStore
  module ValidatesDetails
    extend ActiveSupport::Concern
    included do

      # Only used in tests, so we can easily add a schema to an edition, without
      # having to resort to mocks, which are difficult to setup/clean between tests
      attr_writer :schema
    end

    def schema
      @schema ||= ContentObjectStore::ContentBlockSchema.find_by_block_type(block_type)
    end
  end
end
