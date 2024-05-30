class RepublishingEvent < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :reason, presence: true
  validates :content_id, presence: true, unless: -> { bulk }

  validates :bulk, inclusion: [true, false]
  validates :bulk_content_type, presence: true, if: -> { bulk }

  enum :bulk_content_type, %i[
    all_documents
    all_documents_with_pre_publication_editions
    all_documents_with_pre_publication_editions_with_html_attachments
    all_published_organisation_about_us_pages
  ]
end
