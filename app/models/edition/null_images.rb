module Edition::NullImages
  extend ActiveSupport::Concern

  def images
    []
  end

  def lead_image
    nil
  end

  def allows_image_attachments?
    false
  end
end