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
end
