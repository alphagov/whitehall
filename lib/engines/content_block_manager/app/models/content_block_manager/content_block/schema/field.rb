module ContentBlockManager
  module ContentBlock
    class Schema
      class Field
        attr_reader :name, :schema

        NestedField = Data.define(:name, :format, :enum_values)

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
              NestedField.new(name: key, format: value["type"], enum_values: value["enum"])
            end
          end
        end

        def array_items
          properties.fetch("items", nil)
        end

        def is_required?
          schema.required_fields.include?(name)
        end

      private

        def custom_component
          @custom_component ||= begin
                                  if name == "title" && schema.hide_title?
                                    "hidden_title"
                                  else
                                    config["component"]
                                  end
                                end
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
