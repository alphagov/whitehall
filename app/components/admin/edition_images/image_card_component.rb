# frozen_string_literal: true

class Admin::EditionImages::ImageCardComponent < ViewComponent::Base
  def initialize(edition:, image:, image_usage:)
    @edition = edition
    @image = image
    @image_usage = image_usage
  end

private

  attr_reader :edition, :image, :image_usage

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

    return "<div class=\"js-image-processing-status\"><span class=\"govuk-tag govuk-tag--green\">Processing</span></div>".html_safe unless image.image_data&.original_uploaded? && image.thumbnail

    return "<span class=\"govuk-tag govuk-tag--red\">Requires cropping</span>".html_safe if image.requires_crop?

    sanitize("<img style=\"width: 100%;\" src=\"#{image.thumbnail}\" alt=\"\" class=\"app-view-edition-resource__preview\">")
  end

  def markdown_code
    render("govuk_publishing_components/components/copy_to_clipboard", {
      label: tag.span("Markdown code:", class: "govuk-visually-hidden"),
      copyable_content: image_markdown,
      button_text: "Copy Markdown",
    })
  end

  def image_markdown
    edition.images_have_unique_filenames? ? "[Image: #{image.filename}]" : "!!#{find_image_index + 1}"
  end

  def find_image_index
    edition.images.find_index(image)
  end
end
