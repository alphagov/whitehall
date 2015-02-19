module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy
    has_many :primary_specialist_sectors,
             -> { where(primary: true) },
             class_name: 'SpecialistSector',
             foreign_key: :edition_id
    has_many :secondary_specialist_sectors,
             -> { where(primary: false) },
             class_name: 'SpecialistSector',
             foreign_key: :edition_id

    add_trait do
      def process_associations_before_save(edition)
        @edition.specialist_sectors.each do |sector|
          edition.specialist_sectors << sector.dup
        end
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

  def specialist_sector_tags
    Array(primary_specialist_sector_tag) + secondary_specialist_sector_tags
  end

  def live_specialist_sector_tags
    specialist_sector_tags.select do |tag|
      live_specialist_sector_tag_slugs.include?(tag)
    end
  end

private

  def set_specialist_sectors(tags, primary: false)
    relation = primary ? 'primary_specialist_sectors' : 'secondary_specialist_sectors'

    sectors = tags.reject(&:blank?).map do |tag|
      self.specialist_sectors.where(tag: tag).first_or_initialize.tap do |sector|
        sector.edition = self
        sector.primary = primary
      end
    end

    self.public_send("#{relation}=", sectors)
  end

  def live_specialist_sector_tag_slugs
    @live_specialist_sector_tag_slugs ||= SpecialistSector.live_subsectors.map(&:slug)
  end
end
