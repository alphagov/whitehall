module ContentObjectStore
  class SchemaService
    def self.schema_for_block_type(block_type)
      schema_name = "#{ContentBlockSchema::SCHEMA_PREFIX}_#{block_type}"
      full_schema = Services.publishing_api.get_schema(schema_name)
      initialize_schema(schema_name, full_schema)
    rescue GdsApi::HTTPNotFound
      raise ArgumentError, "Invalid block_type: #{block_type}"
    end

    def self.valid_schemas
      @valid_schemas ||= Services.publishing_api.get_schemas.select { |k, _v|
        k.start_with?(ContentBlockSchema::SCHEMA_PREFIX)
      }.map do |k, v|
        initialize_schema(k, v)
      end
    end

    def self.initialize_schema(id, full_schema)
      schema = full_schema.dig("definitions", "details") || raise(ArgumentError, "Cannot find schema for #{id}")
      ContentObjectStore::ContentBlockSchema.new(id, schema)
    end
  end
end
