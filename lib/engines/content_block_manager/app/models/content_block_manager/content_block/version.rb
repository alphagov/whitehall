module ContentBlockManager
  module ContentBlock
    class Version < ApplicationRecord
      enum :event, %i[created updated]

      belongs_to :item, polymorphic: true
      validates :event, presence: true
      belongs_to :user, foreign_key: "whodunnit"

      def field_diffs
        self[:field_diffs] ? ContentBlock::DiffItem.from_hash(self[:field_diffs]) : {}
      end
    end
  end
end
