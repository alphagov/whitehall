class ImageDetailsSerializer < ActiveModel::Serializer
  attributes :url, :alt_text, :caption

  def url
    Whitehall.public_asset_host + object.lead_image_path
  end

  def alt_text
    object.lead_image_alt_text
  end

  def caption
    object.lead_image_caption
  end
end
