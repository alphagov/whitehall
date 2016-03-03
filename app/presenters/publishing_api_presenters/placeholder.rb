require_relative "../publishing_api_presenters"
# For now, this is used to register data for items in the content
# store as "placeholder" content items. This is so that finders can reference
# items using content_ids and have their basic information expanded
# out when read back out from the content store.
class PublishingApiPresenters::Placeholder < PublishingApiPresenters::Item
private

  def filter_links
    [
      :topics,
    ]
  end

  def title
    item.name
  end

  def description
    nil
  end

  def public_updated_at
    item.updated_at
  end

  def document_format
    "placeholder_#{item.class.name.underscore}"
  end
end
