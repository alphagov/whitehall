module Admin::RepublishingHelper
  include Rails.application.routes.url_helpers

  def bulk_content_type_metadata
    @bulk_content_type_metadata ||= {
      all_documents: {
        id: "all-documents",
        name: "all documents",
        republishing_path: admin_bulk_republishing_all_republish_path("all-documents"),
        confirmation_path: admin_bulk_republishing_all_confirm_path("all-documents"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents },
      },
      all_documents_with_pre_publication_editions: {
        id: "all-documents-with-pre-publication-editions",
        name: "all documents with pre-publication editions",
        republishing_path: admin_bulk_republishing_all_republish_path("all-documents-with-pre-publication-editions"),
        confirmation_path: admin_bulk_republishing_all_confirm_path("all-documents-with-pre-publication-editions"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents_with_pre_publication_editions },
      },
      all_published_organisation_about_us_pages: {
        id: "all-published-organisation-about-us-pages",
        name: "all published organisation 'About us' pages",
        republishing_path: admin_bulk_republishing_all_republish_path("all-published-organisation-about-us-pages"),
        confirmation_path: admin_bulk_republishing_all_confirm_path("all-published-organisation-about-us-pages"),
        republish_method: -> { BulkRepublisher.new.republish_all_published_organisation_about_us_pages },
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
