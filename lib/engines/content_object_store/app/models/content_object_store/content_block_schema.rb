class ContentObjectStore::ContentBlockSchema
  SCHEMA_PREFIX = "content_block".freeze

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
end
