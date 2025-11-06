module Edition::LeadImage
  extend ActiveSupport::Concern

  included do
    has_one :edition_lead_image, foreign_key: :edition_id, dependent: :destroy
    has_one :lead_image, through: :edition_lead_image, source: :image
    validate :image_dimensions, on: :publish
  end

  def has_lead_image?
    !image_data.nil?
  end

  def has_lead_image_ready_for_publishing?
    has_lead_image? && lead_image_has_all_assets? && is_not_too_large?
  end

  def is_not_too_large?
    !image_data.requires_crop?
  end

  def image_dimensions
    unless is_not_too_large?
      errors.add(:lead_image, "is too large and requires cropping")
    end
  end

  def lead_image_url
    image_url
  end

  def high_resolution_lead_image_url
    image_data.file.url(:s960)
  end

  def lead_image_alt_text
    if lead_image.try(:alt_text)
      lead_image.alt_text.squish
    else
      ""
    end
  end

  def lead_image_caption
    if lead_image
      caption = lead_image.caption && lead_image.caption.strip
      caption.presence
    end
  end

  def lead_image_has_all_assets?
    image_data.all_asset_variants_uploaded?
  end

private

  def image_url
    image_data.file.url(:s300)
  end

  def image_data
    if lead_image
      lead_image.image_data
    elsif lead_organisations.any? && lead_organisations.first.default_news_image
      lead_organisations.first.default_news_image
    elsif organisations.any? && organisations.first.default_news_image
      organisations.first.default_news_image
    elsif respond_to?(:worldwide_organisations) && published_worldwide_organisations.any? && published_worldwide_organisations.first.default_news_image
      published_worldwide_organisations.first.default_news_image
    end
  end

  def uploader
    image_data.file
  end

  def file
    uploader.file
  end
end
