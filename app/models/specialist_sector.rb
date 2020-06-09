class SpecialistSector < ApplicationRecord
  belongs_to :edition

  validates :edition, presence: true
  validates :topic_content_id, presence: true, uniqueness: { scope: :edition_id } # rubocop:disable Rails/UniqueValidationWithoutIndex

  def edition
    Edition.unscoped { super }
  end
end
