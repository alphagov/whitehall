# frozen_string_literal: true

class Admin::EditionImages::UploadedImagesComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def has_lead_image
    @has_lead_image ||= @edition.lead_image.present?
  end

  def lead_image
    @lead_image ||= @edition.lead_image
  end

  def lead_image_hash
    image_to_hash(lead_image, 0) if lead_image
  end

  def document_images
    @document_images ||= (@edition.images - [lead_image].compact)
                          .map.with_index(1) { |image, index| image_to_hash(image, index) }
  end

  def new_image_display_option
    if @edition.image_display_option == "no_image"
      return has_lead_image ? "custom_image" : "organisation_image"
    end

    "no_image"
  end

  def update_image_display_option_button_text
    if @edition.images.present?
      return "#{new_image_display_option == 'no_image' ? 'Hide' : 'Show'} lead image"
    end

    "#{new_image_display_option == 'no_image' ? 'Remove lead' : 'Use default'} image"
  end

  def lead_image_guidance
    if @edition.type == "CaseStudy"
      tag.p("Using a lead image is optional and can be shown or hidden. The first image you upload is used as the lead image.", class: "govuk-body") + tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
    else
      tag.p("The first image you upload is used as the lead image.", class: "govuk-body") + tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
    end
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
