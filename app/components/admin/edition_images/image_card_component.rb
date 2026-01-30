# frozen_string_literal: true

class Admin::EditionImages::ImageCardComponent < Admin::EditionImages::ImageComponent
  def initialize(edition:, image:, last_image:, image_kind:)
    super(edition:, image:, last_image:)
    @image_kind = image_kind
  end

private

  attr_reader :edition, :image, :last_image, :image_kind
end
