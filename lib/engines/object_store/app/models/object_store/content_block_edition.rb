class ObjectStore::ContentBlockEdition < ApplicationRecord
  include HasContentId
  include PublishesToPublishingApi

  attr_accessor :title, :block_type

  store_accessor :properties

  validates :properties, presence: true, json: { schema: -> { schema_for_block_type } }

  belongs_to :content_block_document, touch: true
  validates :content_block_document, presence: true
  before_validation :ensure_presence_of_content_block_document, on: :create

  def schema_for_block_type
    ObjectStore::ContentBlockValidator.schema_for(block_type)
  end

  def ensure_presence_of_content_block_document
    if content_block_document.blank?
      self.content_block_document = ObjectStore::ContentBlockDocument.new(
        title:,
        block_type:,
        content_id: SecureRandom.uuid,
      )
    end
  end

  def update_document_edition_references
    content_block_document.update_edition_references
  end

  def can_publish_to_publishing_api?
    # TODO: could be based on what workflow state edition is in
    false
  end
end
