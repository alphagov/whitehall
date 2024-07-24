module ContentObjectStore
  module Documentable
    extend ActiveSupport::Concern

    included do
      belongs_to :content_block_document, touch: true
      validates :content_block_document, presence: true

      before_validation :ensure_presence_of_document, on: :create

      accepts_nested_attributes_for :content_block_document
    end

    alias_attribute :document, :content_block_document

    def title
      document&.title || @title
    end

    def block_type
      document&.block_type || @block_type
    end

    def ensure_presence_of_document
      if document.blank?
        self.document = ContentBlock::Document.new(
          content_id: create_random_id,
          block_type: @block_type,
          title: @title,
        )
      elsif document.new_record?
        document.content_id = create_random_id if document.content_id.blank?
        document.block_type = @block_type if document.block_type.blank?
        document.title = @title if document.title.blank?
      end
    end

    def create_random_id
      SecureRandom.uuid
    end
  end
end
