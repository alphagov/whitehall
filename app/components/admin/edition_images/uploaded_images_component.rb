# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def can_have_lead_image?
    @edition.can_have_custom_lead_image?
  end

  def lead_image
    @lead_image ||= can_have_lead_image? ? @edition.lead_image : nil
  end

  def document_images
    @document_images ||= (@edition.images - [lead_image].compact)
                          .map.with_index(1) { |image, index| image_to_hash(image, index) }
  end

private

  def all_image_asset_variants_uploaded?(image)
    image.image_data.all_asset_variants_uploaded? if image.image_data.present?
  end

  def image_to_hash(image, index)
    {
      url: image.url,
      preview_alt_text: lead_image == image ? "Lead image" : "Image #{index}",
      caption: image.caption.presence || "None",
      alt_text: image.alt_text.presence || "None",
      markdown: unique_names? ? "[Image: #{image.filename}]" : "!!#{index}",
      links: links_for_image(image),
      all_image_asset_variants_uploaded: all_image_asset_variants_uploaded?(image),
    }
  end

  def unique_names?
    return @unique_names if defined? @unique_names

    names = @edition.images.map(&:filename)
    @unique_names = (names.uniq.length == names.length)
  end

  def links_for_image(image)
    links = []
    links << link_to("Edit details", edit_admin_edition_image_path(@edition, image), class: "govuk-link")
    links << link_to("Delete image", confirm_destroy_admin_edition_image_path(@edition, image), class: "govuk-link gem-link--destructive")
    links
  end
end
