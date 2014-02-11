class SpecialistSector < ActiveRecord::Base
  belongs_to :edition

  validates :edition_id, presence: true
  validates :tag, presence: true, uniqueness: { scope: :edition_id }
end
