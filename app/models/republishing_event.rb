class RepublishingEvent < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :reason, presence: true
  validates :bulk, inclusion: [true, false]
  validates :content_id, presence: true, unless: -> { bulk }
  validates :bulk_content_type, presence: true, if: -> { bulk }

  validates :content_type, presence: true, if: -> { bulk_content_type == "all_by_type" }
  validates :content_type, absence: true, unless: -> { bulk_content_type == "all_by_type" }

  enum :bulk_content_type, %i[
    all_documents
    all_documents_with_pre_publication_editions
    all_documents_with_pre_publication_editions_with_html_attachments
    all_documents_with_publicly_visible_editions_with_attachments
    all_documents_with_publicly_visible_editions_with_html_attachments
    all_published_organisation_about_us_pages
    all_by_type
  ]
end
