module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy
    has_many :primary_specialist_sectors, conditions: {primary: true}, class_name: 'SpecialistSector', foreign_key: :edition_id, dependent: :destroy
    has_many :secondary_specialist_sectors, conditions: {primary: false}, class_name: 'SpecialistSector', foreign_key: :edition_id, dependent: :destroy

    add_trait do
      def process_associations_before_save(edition)
        edition.specialist_sectors = @edition.specialist_sectors
      end
    end
  end

  def primary_specialist_sector_tag
    primary_specialist_sectors.first.try(:tag)
  end

  def primary_specialist_sector_tag=(sector_tag)
    set_specialist_sectors([sector_tag], primary: true)
  end

  def secondary_specialist_sector_tags
    secondary_specialist_sectors.map(&:tag)
  end

  def secondary_specialist_sector_tags=(sector_tags)
    set_specialist_sectors(sector_tags, primary: false)
  end

private

  def set_specialist_sectors(tags, primary: false)
    relation = if primary
      'primary_specialist_sectors'
    else
      'secondary_specialist_sectors'
    end

    sectors = tags.reject(&:blank?).map do |tag|
      self.public_send(relation).where(tag: tag).first_or_initialize.tap do |sector|
        sector.edition = self
      end
    end

    self.public_send("#{relation}=", sectors)
  end
end
