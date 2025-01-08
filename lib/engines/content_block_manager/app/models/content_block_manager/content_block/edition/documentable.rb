module ContentBlockManager
  module ContentBlock::Edition::Documentable
    extend ActiveSupport::Concern

    included do
      belongs_to :document, touch: true
      validates :document, presence: true

      before_validation :ensure_presence_of_document, on: :create

      accepts_nested_attributes_for :document
    end

    def block_type
      @block_type ||= document&.block_type
    end

    def ensure_presence_of_document
      if document.new_record?
        document.content_id = create_random_id if document.content_id.blank?
        document.sluggable_string = title if document.sluggable_string.blank?
      end
    end

    def create_random_id
      SecureRandom.uuid
    end
  end
end
