# frozen_string_literal: true

class Admin::EditionImages::LeadImageCardComponent < Admin::EditionImages::ImageCardComponent
private

  def summary_card_actions
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
    else
      [
        {
          label: "Replace",
          href: new_admin_edition_image_path(edition_id: edition.id, usage: image_usage.key),
        },
        {
          label: "Delete",
          href: confirm_update_default_lead_image_behaviour_admin_edition_images_path(edition, behaviour: "no_image"),
          destructive: true,
        },
      ]
    end
  end

  def thumbnail
    if image.blank?
      if edition.default_lead_image&.all_asset_variants_uploaded?
        return sanitize("<img style=\"width: 100%;\" src=\"#{edition.default_lead_image.url(:s300)}\" alt=\"\" class=\"app-view-edition-resource__preview\">")
      else
        return "<img style=\"width: 100%;\" src=\"#{edition.placeholder_image_url}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
      end
    end

    super
  end

  def lead_image_guidance
    tag.p("The lead image appears at the top of the document. The same image should not be used in the body text.", class: "govuk-body") +
      tag.p("Uploading your own lead image is optional. If a custom lead image is not uploaded then the default image for your organisation will be used. If neither is available, a placeholder will appear.", class: "govuk-body")
  end
end
