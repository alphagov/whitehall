module ContentBlockManager
  module ContentBlock
    class Schema
      class EmbeddedSchema < ContentBlockManager::ContentBlock::Schema
        def initialize(id, body, parent_schema_id)
          @parent_schema_id = parent_schema_id
          body = body["patternProperties"]&.values&.first || raise(ArgumentError, "Subschema `#{id}` is invalid")
          super(id, body)
        end

        def fields
          sort_fields @body["properties"].keys
        end

        def block_type
          @id
        end

        private

        def config
          self.class.schema_settings.dig("schemas", @parent_schema_id, "subschemas", @id) || {}
        end
      end
    end
  end
end
