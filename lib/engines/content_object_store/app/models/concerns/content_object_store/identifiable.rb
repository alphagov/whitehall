module ContentObjectStore
  module Identifiable
    extend ActiveSupport::Concern

    included do
      belongs_to :content_block_document, touch: true
      validates :content_block_document, presence: true
      before_validation :ensure_presence_of_document, on: :create
    end

    alias_attribute :document, :content_block_document

    def ensure_presence_of_document
      if document.blank?
        self.document = ContentBlockDocument.new(content_id: create_random_id)
      elsif document.new_record?
        document.content_id = create_random_id if document.content_id.blank?
      end
    end

  private

    def create_random_id
      SecureRandom.uuid
    end
  end
end
