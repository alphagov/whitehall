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
          @format ||= properties["type"]
        end

        def enum_values
          @enum_values ||= properties["enum"]
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
      end
    end
  end
end
