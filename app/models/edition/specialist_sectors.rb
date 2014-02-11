module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy
  end

  def specialist_sector_tags
    specialist_sectors.map(&:tag)
  end
end
