module ContentBlockManager
  module ContentBlock
    class Schema
      class Field
        attr_reader :name, :schema

        NestedField = Data.define(:name, :format, :enum_values, :default_value) do
          def initialize(name:, format:, enum_values:, default_value: nil)
            super(name:, format:, enum_values:, default_value:)
          end
        end

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

        def default_value
          @default_value ||= properties["default"]
        end

        def nested_fields
          if format == "object"
            properties.fetch("properties", {}).map do |key, value|
              NestedField.new(
                name: key,
                format: value["type"],
                enum_values: value["enum"],
                default_value: value["default"],
              )
            end
          end
        end

        def nested_field(name)
          raise(ArgumentError, "Provide the name of a nested field") if name.blank?

          nested_fields.find { |field| field.name == name }
        end

        def array_items
          properties.fetch("items", nil)&.tap do |array_items|
            if array_items["type"] == "object"
              array_items["properties"] = array_items["properties"].sort_by { |k, _v|
                field_ordering_rule.find_index(k) || Float::INFINITY
              }.to_h
            end
          end
        end

        def is_required?
          schema.required_fields.include?(name)
        end

        def data_attributes
          @data_attributes ||= config["data_attributes"] || {}
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

        def field_ordering_rule
          @field_ordering_rule ||= config["field_order"] || []
        end
      end
    end
  end
end
