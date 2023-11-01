# frozen_string_literal: true

class Admin::EditionImages::LeadImageComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

  def render?
    edition.can_have_custom_lead_image?
  end

private

  attr_reader :edition

  def lead_image_guidance
    if case_study?
      tag.p("Using a lead image is optional and can be shown or hidden. The first image you upload is used as the lead image.", class: "govuk-body") + tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
    else
      tag.p("The first image you upload is used as the lead image.", class: "govuk-body") + tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
    end
  end

  def case_study?
    edition.type == "CaseStudy"
  end

  def lead_image
    @lead_image ||= edition.lead_image
  end

  def caption
    lead_image.caption.presence || "None"
  end

  def alt_text
    lead_image.alt_text.presence || "None"
  end

  def new_image_display_option
    @new_image_display_option ||= if image_display_option_is_no_image? && edition_has_images?
                                    "custom_image"
                                  elsif image_display_option_is_no_image?
                                    "organisation_image"
                                  else
                                    "no_image"
                                  end
  end

  def image_display_option_is_no_image?
    edition.image_display_option == "no_image"
  end

  def update_image_display_option_button_text
    return image_display_option_button_text_when_image_has_been_uploaded if edition_has_images?

    image_display_option_button_text_when_no_images_uploaded
  end

  def image_display_option_button_text_when_image_has_been_uploaded
    return "Hide lead image" if new_image_display_option_is_no_image?

    "Show lead image"
  end

  def image_display_option_button_text_when_no_images_uploaded
    return "Remove lead image" if new_image_display_option_is_no_image?

    "Use default image"
  end

  def new_image_display_option_is_no_image?
    new_image_display_option == "no_image"
  end

  def edition_has_images?
    edition.images.present?
  end

  def links
    links = []
    links << link_to("Edit details", edit_admin_edition_image_path(edition, lead_image), class: "govuk-link")
    links << link_to("Delete image", confirm_destroy_admin_edition_image_path(edition, lead_image), class: "govuk-link gem-link--destructive")
    links
  end
end
