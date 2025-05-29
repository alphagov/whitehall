module ContentBlockManager
  module ContentBlock
    class Version < ApplicationRecord
      enum :event, { created: 0, updated: 1 }

      belongs_to :item, polymorphic: true
      validates :event, presence: true
      belongs_to :user, foreign_key: "whodunnit"

      def field_diffs
        self[:field_diffs] ? ContentBlock::DiffItem.from_hash(self[:field_diffs]) : {}
      end

      def is_embedded_update?
        updated_embedded_object_type && updated_embedded_object_title
      end
    end
  end
end
