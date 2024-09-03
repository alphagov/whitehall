module ContentObjectStore
  module ContentBlock
    class Version < ApplicationRecord
      enum event: %i[created updated]

      belongs_to :item, polymorphic: true
      validates :event, presence: true
      belongs_to :user, foreign_key: "whodunnit"
    end
  end
end
