module StandardEdition::DefaultLeadImage
  extend ActiveSupport::Concern

  def default_lead_image
    if respond_to?(:lead_organisations) && lead_organisations.any?
      org = lead_organisations.first
      return org.default_news_image if org&.default_news_image
    end

    if respond_to?(:organisations) && organisations.any?
      org = organisations.first
      return org.default_news_image if org&.default_news_image
    end

    if respond_to?(:worldwide_organisations) && published_worldwide_organisations.any?
      org = published_worldwide_organisations.first
      return org.default_news_image if org&.default_news_image
    end

    nil
  end

  def valid_lead_images
    images.select(&:can_be_lead_image?)
  end

  def placeholder_image_url
    configurable_document_type == "world_news_story" ? "https://assets.publishing.service.gov.uk/media/5e985599d3bf7f3fc943bbd8/UK_government_logo.jpg" : "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg"
  end
end
