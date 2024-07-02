class ContentObjectStore::ContentBlockSchema
  SCHEMA_PREFIX = "content_block".freeze

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def name
    id_without_prefix.humanize
  end

  def parameter
    id_without_prefix.dasherize
  end

private

  def id_without_prefix
    @id_without_prefix ||= id.delete_prefix("#{SCHEMA_PREFIX}_")
  end
end
