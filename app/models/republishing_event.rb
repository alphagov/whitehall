class RepublishingEvent < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :reason, presence: true
  validates :bulk, presence: true
  validates :bulk_content_type, presence: true, if: -> { bulk }
  validates :content_id, presence: true, unless: -> { bulk }

  # should the about us pages include worldwide organisations? If not, should we make it clear that it's only the ones for vanilla organisations?
  enum :bulk_content_type, %i[
    all_about_us_pages
    all_documents
    all_documents_with_pre_publication_editions
    all_documents_with_pre_publication_editions_with_html_attachments
    all_documents_with_publicly_visible_editions_with_attachments
    all_documents_with_publicly_visible_editions_with_html_attachments
    documents_by_content_ids
    documents_by_content_ids_from_csv
    documents_by_organisation
    documents_by_type
    worldwide_corporate_information_pages_by_states
  ]

  def self.humanised_bulk_content_type(bulk_content_type)
    {
      all_about_us_pages: "all about us pages",
      all_documents: "all documents",
      all_documents_with_pre_publication_editions: "all documents with pre-publication editions",
      all_documents_with_pre_publication_editions_with_html_attachments: "all documents with pre-publication editions with HTML attachments",
      all_documents_with_publicly_visible_editions_with_attachments: "all documents with publicly-visible editions with attachments",
      all_documents_with_publicly_visible_editions_with_html_attachments: "all documents with publicly-visible editions with HTML attachments",
      documents_by_content_ids: "documents by content IDs",
      documents_by_content_ids_from_csv: "documents by content IDs from CSV",
      documents_by_organisation: "documents by organisation",
      documents_by_type: "documents by type",
      worldwide_corporate_information_pages_by_states: "worldwide corporate information pages by states",
    }[bulk_content_type]
  end

  ## prevent duplicate scheduling of the same job - about us example
  # if Time.now - RepublishingEvent.all_about_us_pages.last.created_at < 1 hour
  # - show warning text "This republishing job was last added to the queue at
  #   [TIME] and might still be processing. To avoid increased server load and
  #   potential duplication of work, we suggest waiting until [TIME + 1 hour]
  #   then rechecking the content before trying again."
  # - show extra confirmation checkbox "I acknowledge that the republishing job
  #   was last queued at [TIME] but still wish to requeue it"
  # - show error if user doesn't confirm

  ## prevent requeueing individual (index) pages too?

  ## capture these to support checking for recent matching jobs?
  # documents_by_content_ids_from_csv: file_name
  # documents_by_content_ids: content_ids
  # documents_by_organisation: organisation_id/slug
  # documents_by_type: type
  # worldwide_corporate_information_pages_by_states: states
end
