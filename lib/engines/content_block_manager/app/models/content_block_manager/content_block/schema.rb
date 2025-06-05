module ContentBlockManager
  module ContentBlock
    class Schema
      SCHEMA_PREFIX = "content_block".freeze

      VALID_SCHEMAS = %w[pension contact].freeze
      private_constant :VALID_SCHEMAS

      CONFIG_PATH = File.join(ContentBlockManager::Engine.root, "config", "content_block_manager.yml")

      class << self
        def valid_schemas
          Flipflop.show_all_content_block_types? ? VALID_SCHEMAS : %w[pension]
        end

        def all
          @all ||= Services.publishing_api.get_schemas.select { |k, _v|
            is_valid_schema?(k)
          }.map { |id, full_schema|
            full_schema.dig("definitions", "details")&.yield_self { |schema| new(id, schema) }
          }.compact
        end

        def find_by_block_type(block_type)
          all.find { |schema| schema.block_type == block_type } || raise(ArgumentError, "Cannot find schema for #{block_type}")
        end

        def is_valid_schema?(key)
          key.start_with?(SCHEMA_PREFIX) && key.end_with?(*valid_schemas)
        end

        def schema_settings
          @schema_settings ||= YAML.load_file(CONFIG_PATH)
        end
      end

      attr_reader :id, :body

      def initialize(id, body)
        @id = id
        @body = body
      end

      def name
        block_type.humanize
      end

      def parameter
        block_type.dasherize
      end

      def fields
        field_names.map { |field_name| Field.new(field_name, self) }
      end

      def subschema(name)
        subschemas.find { |s| s.id == name }
      end

      def subschemas
        @subschemas ||= embedded_objects.map { |object| EmbeddedSchema.new(*object, @id) }
      end

      def subschemas_for_group(group)
        subschemas.select { |s| s.group == group }
      end

      def permitted_params
        field_names
      end

      def block_type
        @block_type ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
      end

      def embeddable_fields
        config["embeddable_fields"] || []
      end

      def config
        @config ||= self.class.schema_settings.dig("schemas", @id) || {}
      end

      def field_ordering_rule(field)
        if field_order
          # If a field order is found in the config, order by the index. If a field is not found, put it to the end
          field_order.index(field) || 99
        else
          # By default, order with title first
          field == "title" ? 0 : 1
        end
      end

    private

      def field_names
        sort_fields (@body["properties"].to_a - embedded_objects.to_a).to_h.keys
      end

      def sort_fields(fields)
        fields.sort_by { |field| field_ordering_rule(field) }
      end

      def field_order
        @field_order ||= config["field_order"]
      end

      def embedded_objects
        @body["properties"].select { |_k, v| v["type"] == "object" }
      end
    end
  end
end
