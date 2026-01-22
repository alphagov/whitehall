class Admin::EditionImages::ImageUploadComponent < ViewComponent::Base
  attr_reader :edition, :new_image, :image_usage

  def initialize(edition:, image_usage:, new_image: nil)
    @edition = edition
    @new_image = new_image
    @image_usage = image_usage
  end
end
