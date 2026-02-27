module StandardEdition::LeadImage
  extend ActiveSupport::Concern

  DEFAULT_PLACEHOLDER_IMAGE_URL = "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg".freeze
  WORLD_NEWS_STORY_PLACEHOLDER_IMAGE_URL = "https://assets.publishing.service.gov.uk/media/5e985599d3bf7f3fc943bbd8/UK_government_logo.jpg".freeze

  def default_lead_image
    if respond_to?(:lead_organisations) && lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image
    elsif respond_to?(:organisations) && organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image
    elsif respond_to?(:worldwide_organisations) && published_worldwide_organisations.any? && published_worldwide_organisations.first.default_news_image
      published_worldwide_organisations.first.default_news_image
    end
  end

  def placeholder_image_url
    configurable_document_type == "world_news_story" ? WORLD_NEWS_STORY_PLACEHOLDER_IMAGE_URL : DEFAULT_PLACEHOLDER_IMAGE_URL
  end

  def lead_image_payload(lead_image_usage)
    lead_image = images
                   .usable
                   .usable_as(*lead_image_usage)
                   .to_a
                   .select(&:can_be_lead_image?)
                   .first
    if lead_image
      if lead_image.image_data&.all_asset_variants_uploaded?
        return lead_image.publishing_api_details
      end
    elsif default_lead_image&.all_asset_variants_uploaded?
      return default_lead_image.publishing_api_details.merge(type: lead_image_usage.key)
    end

    {
      url: placeholder_image_url,
      content_type: "image/jpeg",
      type: lead_image_usage.key,
    }
  end
end
