class RelatedMainstream < ApplicationRecord
  belongs_to :edition
  validates :content_id, presence: true, uniqueness: { scope: :edition_id, case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :edition_id, presence: true
end
