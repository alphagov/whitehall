module Edition::NullImages
  extend ActiveSupport::Concern

  def images
    []
  end

  def valid_images
    images.select(&:can_be_used?)
  end

  def allows_image_attachments?
    false
  end
end
