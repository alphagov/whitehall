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

  def new_image_display_option
    if @edition.image_display_option == "no_image"
      return has_lead_image? ? "custom_image" : "organisation_image"
    end

    "no_image"
  end

  def update_image_display_option_button_text
    if has_lead_image?
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

  def image_to_hash(image, index)
    {
      url: image.url,
      preview_alt_text: index.zero? ? "Lead image" : "Image #{index}",
      caption: image.caption.presence || "None",
      alt_text: image.alt_text.presence || "None",
      markdown: unique_names? ? "[Image: #{image.filename}]" : "!!#{index}",
      links: links_for_image(image),
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
