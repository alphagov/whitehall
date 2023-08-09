module Edition::LeadImage
  extend ActiveSupport::Concern

  def has_lead_image?
    !image_data.nil?
  end

  def lead_image_url
    image_data ? image_url : placeholder_image_url
  end

  def high_resolution_lead_image_url
    image_data ? image_data.file.url(:s960) : placeholder_image_url
  end

  def lead_image_alt_text
    if images.first.try(:alt_text)
      images.first.alt_text.squish
    else
      ""
    end
  end

  def lead_image_caption
    if images.first
      caption = images.first.caption && images.first.caption.strip
      caption.presence
    end
  end

private

  def placeholder_image_url
    ActionController::Base.helpers.image_url(
      "placeholder.jpg",
      host: Whitehall.public_root,
    )
  end

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
end
