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
      tag.p("Using a lead image is optional. To use a lead image either select the default image for your organisation or upload an image and select it as the lead image.", class: "govuk-body") +
        tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
    else
      tag.p("Any image you upload can be selected as the lead image. If you do not select a new lead image, the default image for your organisation will be used.", class: "govuk-body") +
        tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
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
    @new_image_display_option ||= image_display_option_is_no_image? ? "organisation_image" : "no_image"
  end

  def image_display_option_is_no_image?
    edition.image_display_option == "no_image"
  end

  def update_image_display_option_button_text
    new_image_display_option_is_no_image? ? "Remove lead image" : "Use default image"
  end

  def new_image_display_option_is_no_image?
    new_image_display_option == "no_image"
  end

  def edition_has_images?
    edition.images.present?
  end
end
