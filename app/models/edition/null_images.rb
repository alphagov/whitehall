module Edition::NullImages
  extend ActiveSupport::Concern

  def images
    []
  end

  def allows_image_attachments?
    false
  end
end