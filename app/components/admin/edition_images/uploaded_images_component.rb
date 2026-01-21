# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:, image_kind: Whitehall.image_kinds.fetch("default"))
    @edition = edition
    @image_kind = image_kind
  end

private

  attr_reader :edition

  def document_images
    edition_images = edition.images.select { |image| Whitehall.image_kinds.fetch(image.image_data.image_kind) == @image_kind }

    return edition_images unless edition.can_have_custom_lead_image?

    edition_images - [edition.lead_image].compact
  end
end
