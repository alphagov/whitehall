module Edition::NullWorldLocations
  extend ActiveSupport::Concern

  # We also include this association here so that
  # EditionFilter#in_world_location continues to work, although the
  # method below will stop the UI being shown, meaning that world
  # locations shouldn't be added.

  included do
    has_many :edition_world_locations, foreign_key: :edition_id, inverse_of: :edition, dependent: :destroy, autosave: true
    has_many :world_locations, through: :edition_world_locations
  end

  def can_be_associated_with_world_locations?
    false
  end
end
