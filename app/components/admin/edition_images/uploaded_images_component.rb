# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition

  def document_images
    return edition.images unless edition.can_have_custom_lead_image?

    edition.images - [edition.lead_image].compact
  end
end
