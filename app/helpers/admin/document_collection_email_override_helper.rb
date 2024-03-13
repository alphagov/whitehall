module Admin::DocumentCollectionEmailOverrideHelper
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
