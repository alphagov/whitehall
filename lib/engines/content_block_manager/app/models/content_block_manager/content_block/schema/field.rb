module ContentBlockManager
  module ContentBlock
    class Schema
      class Field
        attr_reader :name, :schema

        def initialize(name, schema)
          @name = name
          @schema = schema
        end

        def to_s
          name
        end

        def component_class
          "ContentBlockManager::ContentBlockEdition::Details::Fields::#{component_name.camelize}Component".constantize
        rescue
          ContentBlockManager::ContentBlockEdition::Details::Fields::StringComponent
        end

        def component_name
          if custom_component
            custom_component
          elsif enum_values
            "enum"
          else
            format
          end
        end

        def format
          @format ||= properties["type"]
        end

        def enum_values
          @enum_values ||= properties["enum"]
        end

        def nested_fields
          nested_field_properties.keys.map do |nested_field|
            ContentBlockManager::ContentBlock::Schema::Field::NestedField.new(
              name: nested_field,
              parent_name: name,
              schema:,
              properties: properties.dig( "properties", nested_field),
              config: config.dig( "fields", nested_field),
            )
          end
        end

        def default_value
          @default_value ||= properties["default"]
        end

      private

        def custom_component
          @custom_component ||= config["component"]
        end

        def properties
          @properties ||= schema.body.dig("properties", name) || {}
        end

        def config
          @config ||= schema.config.dig("fields", name) || {}
        end

        def nested_field_properties
          @nested_field_properties ||= properties["properties"] || {}
        end
      end
    end
  end
end
