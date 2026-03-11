# frozen_string_literal: true

class Admin::EditionImages::ImageCardComponent < Admin::EditionImages::ImageComponent
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
          label: "Add",
          href: new_admin_edition_image_path(edition_id: edition.id, usage: image_usage.key),
        },
      ]
    end
  end

  def caption
    return "Not set" if image.blank?

    image.caption.presence || "Not set"
  end

  def thumbnail
    return "Not set" if image.blank?

    return "<span class=\"govuk-tag govuk-tag--green\">Processing</span>".html_safe unless image.image_data&.original_uploaded? && image.thumbnail

    return "<span class=\"govuk-tag govuk-tag--red\">Requires cropping</span>".html_safe if image.requires_crop?

    sanitize("<img style=\"width: 100%;\" src=\"#{image.thumbnail}\" alt=\"\" class=\"app-view-edition-resource__preview\">")
  end
end
