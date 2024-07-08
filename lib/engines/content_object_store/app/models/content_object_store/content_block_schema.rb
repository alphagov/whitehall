class ContentObjectStore::ContentBlockSchema
  SCHEMA_PREFIX = "content_block".freeze

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def name
    id.delete_prefix(SCHEMA_PREFIX).humanize
  end
end
