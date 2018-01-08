class EditionWorldLocation < ApplicationRecord
  belongs_to :edition
  belongs_to :world_location, inverse_of: :edition_world_locations

  validates :edition, :world_location, presence: true

  scope :with_translations, ->(*locales) { joins(edition: :translations).merge(Edition.with_locales(*locales)) }
end
