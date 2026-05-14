# frozen_string_literal: true

class Admin::EditionImages::ImageComponent < ViewComponent::Base
  def initialize(edition:, image:, image_usage:)
    @edition = edition
    @image = image
    @image_usage = image_usage
  end

private

  attr_reader :edition, :image, :image_usage

  def caption
    image.caption.presence || "None"
  end

  def image_markdown
    edition.images_have_unique_filenames? ? "[Image: #{image.filename}]" : "!!#{find_image_index + 1}"
  end

  def find_image_index
    edition.images.find_index(image)
  end
end
