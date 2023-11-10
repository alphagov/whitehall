module Admin::DocumentCollectionEmailOverrideHelper
  def taxonomy_topic_cannot_be_set?(collection)
    collection.document.live_edition_id.present?
  end

  def has_page_level_notifications?(collection)
    collection.taxonomy_topic_email_override.nil?
  end

  def taxonomy_topic_email_override_title(_collection)
    "My topic title"
  end

  def taxonomy_topic_email_override_base_path(_collection)
    "gov.uk/my-topic"
  end

  def emails_about_this_topic_checked?(collection, params)
    collection.taxonomy_topic_email_override.present? || (params["override_email_subscriptions"] == "true")
  end
end
