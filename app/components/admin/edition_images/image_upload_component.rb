class Admin::EditionImages::ImageUploadComponent < ViewComponent::Base
  attr_reader :edition, :failed_images, :image_usage, :cancel_link

  def initialize(edition:, image_usage:, failed_images: [], cancel_link: nil)
    @edition = edition
    @failed_images = Array(failed_images)
    @image_usage = image_usage
    @cancel_link = cancel_link
  end

  def error_items
    return if failed_images.empty?

    failed_images.flat_map { |image| helpers.errors_for(image.errors, :"image_data.file") }.compact.presence
  end

  def allowed_extensions
    all_allowed_extensions = %w[image/png image/jpeg image/gif image/svg+xml]
    all_allowed_extensions.reject { |ext| ext == "image/svg+xml" if image_usage.lead? }.join(", ")
  end
end
