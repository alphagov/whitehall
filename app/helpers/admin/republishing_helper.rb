module Admin::RepublishingHelper
  include Rails.application.routes.url_helpers

  def bulk_content_type_metadata
    @bulk_content_type_metadata ||= {
      all_organisation_about_us_pages: {
        id: "all-organisation-about-us-pages",
        name: "all organisation 'About Us' pages",
        republishing_path: admin_bulk_republishing_all_organisation_about_us_pages_republish_path,
        confirmation_path: admin_bulk_republishing_all_confirm_path("all-organisation-about-us-pages"),
      }
    }
  end
end
