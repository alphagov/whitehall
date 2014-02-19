module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy

    add_trait do
      def process_associations_before_save(edition)
        edition.specialist_sector_tags = @edition.specialist_sector_tags
      end
    end
  end

  def specialist_sector_tags
    specialist_sectors.map(&:tag)
  end

  def specialist_sector_tags=(sector_tags)
    self.specialist_sectors = Array(sector_tags).reject(&:blank?).map do |tag|
      self.specialist_sectors.where(tag: tag).first_or_initialize.tap do |sector|
        sector.edition = self
      end
    end
  end
end
