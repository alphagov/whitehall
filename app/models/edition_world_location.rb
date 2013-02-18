class EditionWorldLocation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :world_location

  belongs_to :image, class_name: 'EditionWorldLocationImageData', foreign_key: :edition_world_location_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :edition, :world_location, presence: true
  validates :image, :alt_text, presence: true, if: :featured?

  scope :with_translations, lambda { |*locales| joins(edition: :translations).merge(Edition.with_locales(*locales)).merge(Edition.with_required_attributes) }
end
