class Admin::EditionImages::ImageUploadComponent < ViewComponent::Base
  attr_reader :edition, :new_image, :image_usage, :cancel_link

  def initialize(edition:, image_usage:, new_image: nil, cancel_link: nil)
    @edition = edition
    @new_image = new_image
    @image_usage = image_usage
    @cancel_link = cancel_link
  end
end
