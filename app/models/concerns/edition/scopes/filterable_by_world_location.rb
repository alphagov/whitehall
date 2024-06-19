module Edition::Scopes::FilterableByWorldLocation
  extend ActiveSupport::Concern

  included do
    scope :in_world_location, lambda { |world_location|
      joins(:world_locations).where("world_locations.id" => world_location)
    }
  end
end
