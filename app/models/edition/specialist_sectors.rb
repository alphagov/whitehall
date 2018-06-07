# DID YOU MEAN: Topic?
# "Policy area" is the newer name for "topic"
# (https://www.gov.uk/government/topics)
# "Topic" is the newer name for "specialist sector"
# (https://www.gov.uk/topic)
module Edition::SpecialistSectors
  extend ActiveSupport::Concern

  included do
    has_many :specialist_sectors, foreign_key: :edition_id, dependent: :destroy
    has_many :primary_specialist_sectors,
      -> { where(primary: true) },
      class_name: 'SpecialistSector',
      foreign_key: :edition_id,
      dependent: :destroy
    has_many :secondary_specialist_sectors,
      -> { where(primary: false) },
      class_name: 'SpecialistSector',
      foreign_key: :edition_id,
      dependent: :destroy

    add_trait do
      def process_associations_before_save(edition)
        @edition.specialist_sectors.each do |sector|
          edition.specialist_sectors << sector.dup
        end
      end
    end
  end

  def primary_specialist_sector_tag
    primary_specialist_sectors.first.try(:topic_content_id)
  end

  def primary_specialist_sector_tag=(content_id)
    set_specialist_sectors([content_id], primary: true)
  end

  def secondary_specialist_sector_tags
    secondary_specialist_sectors.map(&:topic_content_id)
  end

  def secondary_specialist_sector_tags=(content_ids)
    set_specialist_sectors(content_ids, primary: false)
  end

  def specialist_sector_tags
    specialist_sectors.order("specialist_sectors.primary DESC").map(&:topic_content_id)
  end

  def has_primary_sector?
    !primary_specialist_sector_tag.blank?
  end

  def has_secondary_sectors?
    secondary_specialist_sectors.any?
  end

private

  def set_specialist_sectors(content_ids, primary: false)
    relation = primary ? 'primary_specialist_sectors' : 'secondary_specialist_sectors'

    sectors = content_ids.reject(&:blank?).map do |content_id|
      self.specialist_sectors.where(topic_content_id: content_id).first_or_initialize.tap do |sector|
        sector.edition = self
        sector.primary = primary
      end
    end

    self.public_send("#{relation}=", sectors)
  end
end
