module ContentBlockManager
  module ContentBlock
    class Schema
      class EmbeddedSchema < ContentBlockManager::ContentBlock::Schema
        GOVSPEAK_ENABLED_PROPERTY_KEY = "x-govspeak_enabled".freeze

        def initialize(id, body, parent_schema_id)
          @parent_schema_id = parent_schema_id
          body = body["patternProperties"]&.values&.first || raise(ArgumentError, "Subschema `#{id}` is invalid")
          super(id, body)
        end

        def block_type
          @id
        end

        def embeddable_as_block?
          @embeddable_as_block ||= config["embeddable_as_block"].present?
        end

        def config
          @config ||= self.class.schema_settings.dig("schemas", @parent_schema_id, "subschemas", @id) || {}
        end

        def group
          @group ||= config["group"]
        end

        def group_order
          @group_order ||= config["group_order"]&.to_i || Float::INFINITY
        end

        def permitted_params
          fields.map do |field|
            if field.nested_fields.present?
              { field.name => field.nested_fields.map(&:name) }
            elsif field.format == "array"
              { field.name => [*field.array_items["properties"]&.keys, "_destroy"] || [] }
            else
              field.name
            end
          end
        end

        def govspeak_enabled?(field_name:, nested_object_key: nil)
          return top_level_govspeak_enabled_fields.include?(field_name) unless nested_object_key

          govspeak_enabled_fields_for_nested_object(nested_object_key).include?(field_name)
        end

        def govspeak_enabled_fields_for_nested_object(object_key)
          body.dig("properties", object_key, GOVSPEAK_ENABLED_PROPERTY_KEY) || []
        end

        def top_level_govspeak_enabled_fields
          body.dig("properties", GOVSPEAK_ENABLED_PROPERTY_KEY) || []
        end

      private

        def field_names
          sort_fields @body["properties"].keys
        end
      end
    end
  end
end
