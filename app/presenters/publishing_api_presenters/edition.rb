require_relative "../publishing_api_presenters"

# This base class is used to register dummy items in the content store as
# "placeholder" content items. Only the specialist topics information is
# exposed. This is to enable the email alerts service to generate alerts
# when content is tagged to these topics. Subclasses of this presenter
# will return their own schema name for `document_format`

class PublishingApiPresenters::Edition < PublishingApiPresenters::Item
  def content
    if item.access_limited? && !item.publicly_visible?
      super.merge(access_limited: access_limited)
    else
      super
    end
  end

  def links
    topic_tags = item.specialist_sector_tags
    return {} unless topic_tags.present?

    parent_tag = item.primary_specialist_sector_tag
    base_paths = topic_tags.map { |tag| topic_path_from(tag) }
    content_id_lookup = Whitehall.publishing_api_v2_client.lookup_content_ids(base_paths: base_paths)

    if parent_tag
      parent_content_id = content_id_lookup[topic_path_from(parent_tag)]
      { topics: content_id_lookup.values, parent: [parent_content_id] }
    else
      { topics: content_id_lookup.values }
    end
  end

  def base_path
    Whitehall.url_maker.public_document_path(item)
  end

private

  def topic_path_from(tag)
    "/topic/#{tag}"
  end

  def rendering_app
    item.rendering_app
  end

  def public_updated_at
    # If there is no public_timestamp, the edition should be a draft
    item.public_timestamp || item.updated_at
  end

  def description
    item.summary
  end

  def details
    {
      change_note: item.most_recent_change_note,
      # These tags are used downstream for sending email alerts.
      # For more details please see https://gov-uk.atlassian.net/wiki/display/TECH/Email+alerts+2.0
      tags: {
        browse_pages: [],
        policies: policies,
        topics: specialist_sectors,
      }
    }
  end

  def document_format
    "placeholder"
  end

  def policies
    if item.can_be_related_to_policies?
      item.policies.map(&:slug)
    else
      []
    end
  end

  def specialist_sectors
    [item.primary_specialist_sector_tag].compact + item.secondary_specialist_sector_tags
  end

  def access_limited
    {
      users: users.map(&:uid).compact
    }
  end

  def users
    @users ||= User.where(organisation: item.organisations)
  end

  def default_update_type
    item.minor_change? ? 'minor' : 'major'
  end
end
