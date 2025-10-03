module Edition::LeadImage
  extend ActiveSupport::Concern

  included do
    has_one :edition_lead_image, foreign_key: :edition_id, dependent: :destroy
    has_one :lead_image, through: :edition_lead_image, source: :image
  end

  def has_lead_image?
    !image_data.nil?
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
    image_data&.all_asset_variants_uploaded?
  end

private

  def image_url
    image_data.file.url(:s300)
  end

  def image_data
    lead_image.image_data if lead_image
  end

  def uploader
    image_data.file
  end

  def file
    uploader.file
  end
end
