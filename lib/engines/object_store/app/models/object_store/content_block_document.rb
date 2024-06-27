class ObjectStore::ContentBlockDocument < ApplicationRecord
  include HasContentId

  attr_accessor :title, :block_type

  has_many :content_block_editions,
           -> { order(created_at: :asc, id: :asc) },
           inverse_of: :content_block_document

  has_one  :live_content_block_edition,
           -> { joins(:content_block_document).where("content_block_documents.live_content_block_edition_id = content_block_editions.id") },
           class_name: "ObjectStore::ContentBlockEdition",
           inverse_of: :content_block_document

  def update_edition_references
    latest = content_block_editions.reverse_order
    update!(
      live_content_bloc_edition_id: latest.pick(:id),
    )
  end
end
