module Edition::WorldLocations
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.edition_world_locations.each do |association|
        edition.edition_world_locations.build(association.attributes.except("id"))
      end
    end
  end

  included do
    add_trait Trait
  end

  def can_be_associated_with_world_locations?
    true
  end

  module InstanceMethods
    def search_index
      super.merge("world_locations" => world_locations.map(&:slug))
    end
  end
end