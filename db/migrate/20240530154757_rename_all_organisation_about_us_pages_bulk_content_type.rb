class RenameAllOrganisationAboutUsPagesBulkContentType < ActiveRecord::Migration[7.1]
  def up
    RepublishingEvent
      .where(bulk_content_type: :all_organisation_about_us_pages)
      .update_all(
        bulk_content_type: :all_published_organisation_about_us_pages,
        action: "All published organisation 'About us' pages have been queued for republishing",
      )
  end

  def down
    RepublishingEvent
      .where(bulk_content_type: :all_published_organisation_about_us_pages)
      .update_all(
        bulk_content_type: :all_organisation_about_us_pages,
        action: "All published organisation 'About Us' pages have been queued for republishing",
      )
  end
end
