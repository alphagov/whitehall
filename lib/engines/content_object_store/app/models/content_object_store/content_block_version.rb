class ContentObjectStore::ContentBlockVersion < ApplicationRecord
  enum event: [:created]

  belongs_to :item, polymorphic: true
  validates :event, presence: true
  belongs_to :user, foreign_key: "whodunnit"
end
