# == Schema Information
#
# Table name: edition_world_locations
#
#  id                :integer          not null, primary key
#  edition_id        :integer
#  world_location_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class EditionWorldLocation < ActiveRecord::Base
  extend DeprecatedColumns

  belongs_to :edition
  belongs_to :world_location

  validates :edition, :world_location, presence: true

  deprecated_columns :featured, :ordering, :edition_world_location_image_data_id, :alt_text

  scope :with_translations, -> *locales { joins(edition: :translations).merge(Edition.with_locales(*locales)).merge(Edition.with_required_attributes) }
end
