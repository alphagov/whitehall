require_relative "../publishing_api_presenters"

class PublishingApiPresenters::MinisterialRole < PublishingApiPresenters::Item
  def links
    extract_links([:organisations])
  end

private

  def title
    item.name
  end

  def description
    nil
  end

  def public_updated_at
    item.updated_at
  end

  def schema_name
    "placeholder"
  end

  def document_type
    item.class.name.underscore
  end
end
