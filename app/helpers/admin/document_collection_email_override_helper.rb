module Admin::DocumentCollectionEmailOverrideHelper
  def taxonomy_topic_cannot_be_set?(collection)
    collection.document.live_edition_id.present?
  end

  def has_page_level_notifications?(collection)
    collection.taxonomy_topic_email_override.nil?
  end

  def taxonomy_topic_email_override_title(collection)
    taxonomy_topic_content_item(collection).fetch("title", "")
  end

  def taxonomy_topic_email_override_base_path(collection)
    taxonomy_topic_content_item(collection).fetch("base_path", "")
  end

  def taxonomy_topic_content_item(collection)
    @taxonomy_topic_content_item ||= Services.publishing_api
                                             .get_content(collection.taxonomy_topic_email_override)
                                             .to_h
  rescue GdsApi::HTTPNotFound
    {}
  end
end
