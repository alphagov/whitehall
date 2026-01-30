# Preload real configurable document types
REAL_CONFIGURABLE_DOCUMENT_TYPES = Dir.glob(Rails.root.join("app/models/configurable_document_types/*.json")).each_with_object({}) do |filename, hash|
  data = JSON.parse(File.read(filename))
  hash[data["key"]] = data
end

# Avoids test pollution by only loading the 'topical_event' type when specifically requested,
# preventing ConfigurableDocumentType::NotFoundError during TopicalEvent tests.
# Required by test_helper.rb and features/support/env.rb.
class ConfigurableDocumentType
  class << self
    alias_method :original_find, :find

    def find(type_key)
      original_find(type_key)
    rescue NotFoundError
      if type_key == "topical_event"
        return new(REAL_CONFIGURABLE_DOCUMENT_TYPES["topical_event"])
      end

      raise
    end
  end
end
