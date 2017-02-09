module LeadImagePresenterHelper
  def lead_image_path
    if images.first
      images.first.url(:s300)
    elsif lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image.file.url(:s300)
    elsif organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image.file.url(:s300)
    elsif respond_to?(:worldwide_organisations) && worldwide_organisations.any? && worldwide_organisations.first.default_news_image
      worldwide_organisations.first.default_news_image.file.url(:s300)
    else
      "placeholder.jpg"
    end
  end

  def lead_image_alt_text
    if images.first
      images.first.alt_text.squish
    else
      'placeholder'
    end
  end

  def lead_image_caption
    if images.first
      caption = images.first.caption && images.first.caption.strip
      caption.present? ? caption : nil
    end
  end

private

  def placeholder_image_exisits?
    find_asset("organisation_default_news/s300_#{organisations.first.slug}.jpg")
  end

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
