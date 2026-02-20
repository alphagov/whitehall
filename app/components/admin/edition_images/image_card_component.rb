# frozen_string_literal: true

class Admin::EditionImages::ImageCardComponent < Admin::EditionImages::ImageComponent
private

  def caption
    return "Not set" if image.blank?

    image.caption.presence || "Not set"
  end

  def thumbnail
    if image_usage.lead? && image.blank?
      if edition.default_lead_image&.all_asset_variants_uploaded?
        return "<img style=\"width: 100%;\" src=\"#{edition.default_lead_image.url(:s300)}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
      else
        return "<img style=\"width: 100%;\" src=\"#{edition.placeholder_image_url}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
      end
    end

    return "Not set" if image.blank?

    return "<span class=\"govuk-tag govuk-tag--green\">Processing</span>".html_safe unless image.image_data&.original_uploaded? && image.thumbnail

    return "<span class=\"govuk-tag govuk-tag--red\">Requires cropping</span>".html_safe if image.requires_crop?

    "<img style=\"width: 100%;\" src=\"#{image.thumbnail}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
  end

  def lead_image_guidance
    tag.p("The lead image appears at the top of the document. The same image should not be used in the body text.", class: "govuk-body") +
      tag.p("Uploading your own lead image is optional. If a custom lead image is not uploaded then the default image for your organisation will be used. If neither is available, a placeholder will appear.", class: "govuk-body")
  end
end
