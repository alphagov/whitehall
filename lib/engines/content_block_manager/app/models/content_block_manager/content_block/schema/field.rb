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

        def component_name
          if custom_component
            custom_component
          elsif format == "string"
            enum_values ? "enum" : "string"
          end
        end

        def format
          @format ||= schema.body.dig("properties", name, "type")
        end

        def enum_values
          @enum_values ||= schema.body.dig("properties", name, "enum")
        end

        def default_value
          @default_value ||= schema.body.dig("properties", name, "default")
        end

      private

        def custom_component
          @custom_component ||= schema.config.dig("fields", name, "component")
        end
      end
    end
  end
end
