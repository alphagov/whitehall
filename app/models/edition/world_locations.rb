module Edition::WorldLocations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_world_locations.each do |association|
        edition.edition_world_locations.build(association.attributes.except(["id", "edition_id"]))
      end
    end
  end

  included do
    validate :at_least_one_world_location

    has_many :edition_world_locations, foreign_key: :edition_id, dependent: :destroy, autosave: true
    has_many :world_locations, through: :edition_world_locations

    add_trait Trait
  end

  def can_be_associated_with_world_locations?
    true
  end

  def skip_world_location_validation?
    true
  end

  def at_least_one_world_location
    unless skip_world_location_validation?
      if world_locations.empty?
        errors[:world_locations] = "at least one required"
      end
    end
  end

  module InstanceMethods
    def search_index
      super.merge("world_locations" => world_locations.map(&:slug))
    end
  end
end
