module Admin::RepublishingHelper
  include Rails.application.routes.url_helpers
  include Admin::EditionsHelper

  def bulk_content_type_metadata
    @bulk_content_type_metadata ||= {
      all_documents: {
        id: "all-documents",
        name: "all documents",
        republishing_path: admin_bulk_republishing_republish_path("all-documents"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-documents"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents },
      },
      all_documents_with_pre_publication_editions: {
        id: "all-documents-with-pre-publication-editions",
        name: "all documents with pre-publication editions",
        republishing_path: admin_bulk_republishing_republish_path("all-documents-with-pre-publication-editions"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-documents-with-pre-publication-editions"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents_with_pre_publication_editions },
      },
      all_documents_with_pre_publication_editions_with_html_attachments: {
        id: "all-documents-with-pre-publication-editions-with-html-attachments",
        name: "all documents with pre-publication editions with HTML attachments",
        republishing_path: admin_bulk_republishing_republish_path("all-documents-with-pre-publication-editions-with-html-attachments"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-documents-with-pre-publication-editions-with-html-attachments"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments },
      },
      all_documents_with_publicly_visible_editions_with_attachments: {
        id: "all-documents-with-publicly-visible-editions-with-attachments",
        name: "all documents with publicly-visible editions with attachments",
        republishing_path: admin_bulk_republishing_republish_path("all-documents-with-publicly-visible-editions-with-attachments"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-documents-with-publicly-visible-editions-with-attachments"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_attachments },
      },
      all_documents_with_publicly_visible_editions_with_html_attachments: {
        id: "all-documents-with-publicly-visible-editions-with-html-attachments",
        name: "all documents with publicly-visible editions with HTML attachments",
        republishing_path: admin_bulk_republishing_republish_path("all-documents-with-publicly-visible-editions-with-html-attachments"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-documents-with-publicly-visible-editions-with-html-attachments"),
        republish_method: -> { BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_html_attachments },
      },
      all_non_editionable_content: {
        id: "all-non-editionable-content",
        name: "all non-editionable content",
        republishing_path: admin_bulk_republishing_republish_path("all-non-editionable-content"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-non-editionable-content"),
        republish_method: -> { BulkRepublisher.new.republish_all_non_editionable_content },
      },
      all_published_organisation_about_us_pages: {
        id: "all-published-organisation-about-us-pages",
        name: "all published organisation 'About us' pages",
        republishing_path: admin_bulk_republishing_republish_path("all-published-organisation-about-us-pages"),
        confirmation_path: admin_bulk_republishing_confirm_path("all-published-organisation-about-us-pages"),
        republish_method: -> { BulkRepublisher.new.republish_all_published_organisation_about_us_pages },
      },
      all_by_type: {
        id: "all-by-type",
        name: "all by type",
        new_path: admin_bulk_republishing_by_type_new_path,
        republish_method: ->(type) { BulkRepublisher.new.republish_all_by_type(type) },
      },
      all_documents_by_organisation: {
        id: "all-documents-by-organisation",
        name: "all documents by organisation",
        new_path: admin_bulk_republishing_documents_by_organisation_new_path,
        republish_method: ->(organisation) { BulkRepublisher.new.republish_all_documents_by_organisation(organisation) },
      },
      all_documents_by_content_ids: {
        id: "all-documents-by-content-ids",
        name: "all documents by content IDs",
        new_path: admin_bulk_republishing_documents_by_content_ids_new_path,
        republish_method: ->(document_ids) { BulkRepublisher.new.republish_all_documents_by_ids(document_ids) },
      },
    }
  end

  def republishable_content_types
    editionable_content_types = %w[
      CallForEvidence
      CaseStudy
      Consultation
      CorporateInformationPage
      DetailedGuide
      DocumentCollection
      WorldwideOrganisation
      FatalityNotice
      LandingPage
      NewsArticle
      Publication
      Speech
      StatisticalDataSet
    ]

    [*editionable_content_types, *non_editionable_content_types].sort
  end

  def republishable_content_types_select_options
    republishable_content_types.map do |type|
      {
        text: type,
        value: type.underscore.dasherize,
      }
    end
  end

  def republishing_index_bulk_republishing_rows
    bulk_content_type_metadata.values.map do |content_type|
      [
        {
          text: content_type[:name].upcase_first,
        },
        {
          text: link_to(sanitize("Republish #{tag.span(content_type[:name], class: 'govuk-visually-hidden')}"),
                        content_type[:new_path] || content_type[:confirmation_path],
                        id: content_type[:id],
                        class: "govuk-link"),
        },
      ]
    end
  end

  def non_editionable_content_types
    %w[
      Contact
      Government
      HistoricalAccount
      OperationalField
      Organisation
      Person
      PolicyGroup
      Role
      RoleAppointment
      StatisticsAnnouncement
      TakePartPage
      TopicalEvent
      TopicalEventAboutPage
      WorldLocationNews
    ]
  end

  def content_ids_string_to_array(content_ids_string)
    content_ids_string
      .split(Regexp.union([/\s+/, /\s*,+\s*/]))
      .reject(&:empty?)
  end

  def content_ids_array_to_string(content_ids_array)
    raise "No IDs provided" if content_ids_array.empty?

    central_string = content_ids_array.to_sentence(
      words_connector: "', '",
      two_words_connector: "' and '",
      last_word_connector: "', and '",
    )

    "'#{central_string}'"
  end

  def confirm_documents_by_content_ids_edition_rows(documents)
    documents.map { |document|
      document.republishable_editions.map do |edition|
        [
          { text: edition_title_link_or_edition_title(edition) },
          { text: edition.state.humanize },
          { text: document.content_id },
        ]
      end
    }.flatten(1)
  end
end
