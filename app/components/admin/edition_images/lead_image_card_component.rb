# frozen_string_literal: true

class Admin::EditionImages::LeadImageCardComponent < Admin::EditionImages::ImageCardComponent
private

  def summary_card_actions
    return [] unless edition.editable?

    if image.present?
      [
        {
          label: "Edit",
          href: edit_admin_edition_image_path(edition, image),
          destructive: false,
        },
        {
          label: "Delete",
          href: confirm_destroy_admin_edition_image_path(edition, image),
          destructive: true,
        },
      ]
    elsif show_fallback_image?
      [
        {
          label: "Replace",
          href: new_admin_edition_image_path(edition_id: edition.id, usage: image_usage.key),
        },
        {
          label: "Delete",
          href: confirm_toggle_default_lead_image_behaviour_admin_edition_images_path(edition),
          destructive: true,
        },
      ]
    else
      [
        {
          label: "Add image",
          href: new_admin_edition_image_path(edition_id: edition.id, usage: image_usage.key),
        },
        {
          label: "Use default image",
          href: confirm_toggle_default_lead_image_behaviour_admin_edition_images_path(edition),
        },
      ]
    end
  end

  def thumbnail
    if image.blank? && show_fallback_image?
      if edition.default_lead_image&.all_asset_variants_uploaded?
        return sanitize("<img style=\"width: 100%;\" src=\"#{edition.default_lead_image.url(:s300)}\" alt=\"\" class=\"app-view-edition-resource__preview\">")
      else
        return "<img style=\"width: 100%;\" src=\"#{edition.placeholder_image_url}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
      end
    end

    super
  end

  def lead_image_guidance
    tag.p("Using a lead image is optional. To use a lead image either select the default image for your organisation or upload an image and select it as the lead image.", class: "govuk-body") +
      tag.p("The lead image appears at the top of the document. The same image cannot be used in the body text.", class: "govuk-body")
  end

  def show_fallback_image?
    edition.image_display_option.nil?
  end
end
