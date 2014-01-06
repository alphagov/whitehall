class EditionWorldLocation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :world_location

  validates :edition, :world_location, presence: true

  scope :with_translations, -> *locales { joins(edition: :translations).merge(Edition.with_locales(*locales)).merge(Edition.with_required_attributes) }
end
