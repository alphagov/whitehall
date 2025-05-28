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
          puts "here in format"
          puts schema.body
          @format ||= schema.body["properties"]&.key?("block_attributes") ? schema.body.dig("properties", "block_attributes", "properties", name, "type") : schema.body.dig("properties", name, "type")
        end

        def enum_values
          @enum_values ||= schema.body["properties"]&.key?("block_attributes") ? schema.body.dig("properties", "block_attributes", "properties", name, "enum") : schema.body.dig("properties", name, "enum")
        end

      private

        def custom_component
          @custom_component ||= schema.config.dig("fields", name, "component")
        end
      end
    end
  end
end
