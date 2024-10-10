module ContentBlockManager
  module ContentBlock::Edition::ValidatesDetails
    extend ActiveSupport::Concern

    DETAILS_PREFIX = "details_".freeze

    included do
      validates_with ContentBlockManager::DetailsValidator

      # Only used in tests, so we can easily add a schema to an edition, without
      # having to resort to mocks, which are difficult to setup/clean between tests
      attr_writer :schema

      def self.human_attribute_name(attr, options = {})
        if attr.starts_with?(DETAILS_PREFIX)
          key = attr.to_s.delete_prefix(DETAILS_PREFIX)
          key.humanize
        else
          super attr, options
        end
      end
    end

    def schema
      @schema ||= ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
    end

    # When an error is raised about a field within the details hash
    # we have to prefix it. This overrides the default `read_attribute_for_validation`
    # method, and reads it from the details hash if the attribute name
    # is prefixes
    def read_attribute_for_validation(attr)
      if attr.starts_with?(DETAILS_PREFIX)
        key = attr.to_s.delete_prefix(DETAILS_PREFIX)
        details&.fetch(key, nil)
      else
        super(attr)
      end
    end
  end
end
