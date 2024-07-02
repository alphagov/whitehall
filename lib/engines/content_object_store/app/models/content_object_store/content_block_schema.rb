class ContentObjectStore::ContentBlockSchema
  SCHEMA_PREFIX = "content_block".freeze

  attr_reader :id

  def initialize(id, body)
    @id = id
    @body = body
  end

  def name
    id_without_prefix.humanize
  end

  def parameter
    id_without_prefix.dasherize
  end

  def fields
    @body["properties"].keys
  end

private

  def id_without_prefix
    @id_without_prefix ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
  end
end
