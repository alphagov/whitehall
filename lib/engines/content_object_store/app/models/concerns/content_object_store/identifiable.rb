module ContentObjectStore
  module Identifiable
    extend ActiveSupport::Concern

    included do
      belongs_to :content_block_document, touch: true
      validates :content_block_document, presence: true
      validates :block_type, presence: true

      before_validation :ensure_presence_of_document, on: :create

      attr_accessor :block_type, :document_title
    end

    alias_attribute :document, :content_block_document
    delegate :title, to: :document, allow_nil: true

    def ensure_presence_of_document
      if document.blank?
        self.document = ContentBlockDocument.new(
          content_id: create_random_id,
          block_type:,
          title: document_title,
        )
      elsif document.new_record?
        document.content_id = create_random_id if document.content_id.blank?
        document.block_type = block_type if document.block_type.blank?
        document.title = document_title if document.title.blank?
      end
    end

    def create_random_id
      SecureRandom.uuid
    end
  end
end
