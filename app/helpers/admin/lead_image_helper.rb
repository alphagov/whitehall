module Admin::LeadImageHelper
  def lead_image_fallback_thumbnail(edition)
    if edition.default_lead_image&.all_asset_variants_uploaded?
      sanitize("<img style=\"width: 100%;\" src=\"#{edition.default_lead_image.url(:s300)}\" alt=\"\" class=\"app-view-edition-resource__preview\">")
    else
      "<img style=\"width: 100%;\" src=\"#{edition.placeholder_image_url}\" alt=\"\" class=\"app-view-edition-resource__preview\">".html_safe
    end
  end
end
