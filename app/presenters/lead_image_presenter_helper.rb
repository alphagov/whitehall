module LeadImagePresenterHelper
  def lead_image_path
    if image_data
      image_url
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

  def image_url
    content_type = file.content_type
    if content_type && content_type =~ /svg/
      image_data.file.url
    else
      image_data.file.url(:s300)
    end
  end

  def image_data
    if images.first
      images.first.image_data
    elsif lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image
    elsif organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image
    elsif respond_to?(:worldwide_organisations) && worldwide_organisations.any? && worldwide_organisations.first.default_news_image
      worldwide_organisations.first.default_news_image
    end
  end

  def uploader
    image_data.file
  end

  def file
    uploader.file
  end

  def find_asset(asset)
    Rails.application.assets.find_asset(asset)
  end
end
