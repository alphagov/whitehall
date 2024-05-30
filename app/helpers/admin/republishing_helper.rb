module Admin::RepublishingHelper
  include Rails.application.routes.url_helpers

  def bulk_content_type_metadata
    @bulk_content_type_metadata ||= {
      all_organisation_about_us_pages: {
        id: "all-organisation-about-us-pages",
        name: "all organisation 'About Us' pages",
        republishing_path: admin_bulk_republishing_all_republish_path("all-organisation-about-us-pages"),
        confirmation_path: admin_bulk_republishing_all_confirm_path("all-organisation-about-us-pages"),
        republish_method: -> { BulkRepublisher.new.republish_all_organisation_about_us_pages },
      },
    }
  end

  def republishing_index_bulk_republishing_rows
    bulk_content_type_metadata.values.map do |content_type|
      [
        {
          text: content_type[:name].upcase_first,
        },
        {
          text: link_to(sanitize("Republish #{tag.span(content_type[:name], class: 'govuk-visually-hidden')}"),
                        content_type[:confirmation_path],
                        id: content_type[:id],
                        class: "govuk-link"),
        },
      ]
    end
  end
end
