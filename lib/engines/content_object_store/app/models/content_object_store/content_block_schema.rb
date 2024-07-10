class ContentObjectStore::ContentBlockSchema
  SCHEMA_PREFIX = "content_block".freeze

  VALID_SCHEMAS = %w[email_address].freeze
  private_constant :VALID_SCHEMAS

  def self.valid_schemas
    VALID_SCHEMAS
  end

  attr_reader :id

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
    @body["properties"].keys
  end

  def block_type
    @block_type ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
  end

  def self.all
    @all ||= Services.publishing_api.get_schemas.select { |k, _v|
      is_valid_schema?(k)
    }.map { |id, full_schema|
      full_schema.dig("definitions", "details")&.yield_self { |schema| new(id, schema) }
    }.compact
  end

  def self.find_by_block_type(block_type)
    all.find { |schema| schema.block_type == block_type } || raise(ArgumentError, "Cannot find schema for #{block_type}")
  end

  def self.is_valid_schema?(key)
    key.start_with?(SCHEMA_PREFIX) && key.end_with?(*valid_schemas)
  end
end
