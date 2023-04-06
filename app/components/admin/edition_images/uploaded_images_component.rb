# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
    @lead_image = has_lead_image? ? @edition.images.first : nil
    @document_images = @edition.images.drop(has_lead_image? ? 1 : 0)
  end

  def has_lead_image?
    can_have_lead_image? && @edition.images.any?
  end

  def can_have_lead_image?
    @edition.is_a? Edition::FirstImagePulledOut
  end

  def lead_image
    image_to_hash @lead_image, 0 if has_lead_image?
  end

  def document_images
    @document_images.map.with_index(1) { |image, index| image_to_hash image, index }
  end

private

  def image_to_hash(image, index)
    {
      url: image.url,
      preview_alt_text: index.zero? ? "Lead image" : "Image #{index}",
      caption: image.caption.presence || "None",
      alt_text: image.alt_text.presence || "None",
      markdown: "[#{image.image_data.carrierwave_image}]",
      links: links_for_image(image),
    }
  end

  def links_for_image(image)
    links = []
    links << link_to("Edit details", edit_admin_edition_image_path(@edition, image), class: "govuk-link")
    links << link_to("Delete image", confirm_destroy_admin_edition_image_path(@edition, image), class: "govuk-link gem-link--destructive")
    links
  end
end
