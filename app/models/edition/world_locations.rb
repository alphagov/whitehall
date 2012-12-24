module Edition::WorldLocations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.world_locations = @edition.world_locations
    end
  end

  included do
    has_many :edition_world_locations, foreign_key: :edition_id, dependent: :destroy
    has_many :world_locations, through: :edition_world_locations

    add_trait Trait
  end

  def can_be_associated_with_world_locations?
    true
  end

  module ClassMethods
    def in_world_location(world_location)
      joins(:world_locations).where('world_locations.id' => world_location)
    end
  end
end