class RelatedMainstream < ApplicationRecord
  belongs_to :edition, foreign_key: :edition_id
  validates :content_id, presence: true, uniqueness: { scope: :edition_id } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :edition_id, presence: true
end
