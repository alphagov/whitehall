# frozen_string_literal: true

class Admin::EditionImages::ImageComponent < ViewComponent::Base
  def initialize(edition:, image:, last_image:)
    @edition = edition
    @image = image
    @last_image = last_image
  end

private

  attr_reader :edition, :image, :last_image

  def preview_alt_text
    "Image #{find_index_from_non_lead_images + 1}"
  end

  def caption
    image.caption.presence || "None"
  end

  def alt_text
    image.alt_text.presence || "None"
  end

  def image_markdown
    edition.images_have_unique_filenames? ? "[Image: #{image.filename}]" : "!!#{find_image_index + 1}"
  end

  def find_index_from_non_lead_images
    if edition.respond_to?(:non_lead_images)
      edition.non_lead_images.find_index(image)
    else
      edition.images.find_index(image)
    end
  end

  def find_image_index
    edition.images.find_index(image)
  end
end
