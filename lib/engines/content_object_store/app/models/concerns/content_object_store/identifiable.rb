module ContentObjectStore
  module Identifiable
    extend ActiveSupport::Concern

    included do
      belongs_to :content_block_document, touch: true
      validates :content_block_document, presence: true
      validates :block_type, presence: true

      before_validation :ensure_presence_of_document, on: :create

      attr_accessor :block_type
    end

    alias_attribute :document, :content_block_document

    def ensure_presence_of_document
      if document.blank?
        self.document = ContentBlockDocument.new(
          content_id: create_random_id,
          block_type: self.block_type
        )
      elsif document.new_record?
        document.content_id = create_random_id if document.content_id.blank?
        document.block_type = self.block_type if document.block_type.blank?
      end
    end

  private

    def create_random_id
      SecureRandom.uuid
    end
  end
end
