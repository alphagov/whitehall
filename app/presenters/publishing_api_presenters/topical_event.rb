require_relative "../publishing_api_presenters"

class PublishingApiPresenters::TopicalEvent < PublishingApiPresenters::Item
  def details
    super.tap do |details|
      details[:start_date] = item.start_date.to_datetime if item.start_date
      details[:end_date] = item.end_date.to_datetime if item.end_date
    end
  end

  def title
    item.name
  end

  def description
    nil
  end

  def schema_name
    "placeholder"
  end

  def document_type
    item.class.name.underscore
  end

  def public_updated_at
    item.updated_at
  end

  def links
    extract_links([:organisations])
  end
end
