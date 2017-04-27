module LeadImagePresenterHelper
  def lead_image_path
    if image
      image.url(:s300)
    else
      "placeholder.jpg"
    end
  end

  def lead_image_alt_text
    if images.first
      image.alt_text.squish
    else
      'placeholder'
    end
  end

  def lead_image_caption
    if images.first
      caption = image.caption && image.caption.strip
      caption.present? ? caption : nil
    end
  end

private

  def image
    if images.first
      images.first
    elsif lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image.file
    elsif organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image.file
    elsif respond_to?(:worldwide_organisations) && worldwide_organisations.any? && worldwide_organisations.first.default_news_image
      worldwide_organisations.first.default_news_image.file
    end
  end

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
