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
    extract_links([:organisations, :topics, :parent])
  end

  def base_path
    Whitehall.url_maker.public_document_path(item, locale: I18n.locale)
  end

private

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
      # These tags are used downstream for sending email alerts.
      # For more details please see https://gov-uk.atlassian.net/wiki/display/TECH/Email+alerts+2.0
      tags: {
        browse_pages: [],
        policies: policies,
        topics: specialist_sectors,
      }
    }
  end

  def schema_name
    "placeholder_#{item.class.name.underscore}"
  end

  def document_type
    item.display_type_key
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

  def first_public_at
    if item.document.published?
      item.first_public_at
    else
      item.document.created_at.iso8601
    end
  end

  def body
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(item)
  end
end
