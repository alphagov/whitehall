module StandardEdition::DefaultLeadImage
  extend ActiveSupport::Concern

  def default_lead_image
    if respond_to?(:lead_organisations) && lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image
    elsif respond_to?(:organisations) && organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image
    elsif respond_to?(:worldwide_organisations) && published_worldwide_organisations.any? && published_worldwide_organisations.first.default_news_image
      published_worldwide_organisations.first.default_news_image
    end
  end

  def non_svg_images
    images.reject(&:svg?)
  end
end
