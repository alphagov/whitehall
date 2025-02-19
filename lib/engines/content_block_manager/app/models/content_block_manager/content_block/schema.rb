module ContentBlockManager
  module ContentBlock
    class Schema
      SCHEMA_PREFIX = "content_block".freeze

      VALID_SCHEMAS = %w[email_address postal_address pension].freeze
      private_constant :VALID_SCHEMAS

      CONFIG_PATH = File.join(ContentBlockManager::Engine.root, "config", "content_block_manager.yml")

      class << self
        def valid_schemas
          VALID_SCHEMAS
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
        (@body["properties"].to_a - embedded_objects.to_a).to_h.keys
      end

      def subschema(name)
        subschemas.find { |s| s.id == name }
      end

      def subschemas
        @subschemas ||= embedded_objects.map { |object| EmbeddedSchema.new(*object, @id) }
      end

      def permitted_params
        fields
      end

      def block_type
        @block_type ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
      end

      def embeddable_fields
        config["embeddable_fields"] || fields
      end

      class EmbeddedSchema < Schema
        def initialize(id, body, parent_schema_id)
          @parent_schema_id = parent_schema_id
          body = body["patternProperties"]&.values&.first || raise(ArgumentError, "Subschema `#{id}` is invalid")
          super(id, body)
        end

        def fields
          @body["properties"].keys.sort_by { |field| @body["order"]&.index(field) }
        end

        def block_type
          @id
        end

      private

        def config
          self.class.schema_settings.dig("schemas", @parent_schema_id, "subschemas", @id) || {}
        end
      end

    private

      def embedded_objects
        @body["properties"].select { |_k, v| v["type"] == "object" }
      end

      def config
        @config ||= self.class.schema_settings.dig("schemas", @id) || {}
      end
    end
  end
end
