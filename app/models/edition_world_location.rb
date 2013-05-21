class EditionWorldLocation < ActiveRecord::Base
  extend DeprecatedColumns

  belongs_to :edition
  belongs_to :world_location

  validates :edition, :world_location, presence: true

  # deprecated_columns :featured, :ordering, :edition_world_location_image_data_id, :alt_text

  scope :with_translations, -> *locales { joins(edition: :translations).merge(Edition.with_locales(*locales)).merge(Edition.with_required_attributes) }
end
