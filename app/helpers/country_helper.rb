module CountryHelper
  def current_world_location_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def array_of_links_to_world_locations(world_locations)
    world_locations.map do |world_location|
      link_to(world_location.name, world_location, class: 'world-location-link')
    end
  end

  def array_of_links_to_worldwide_organisations(worldwide_organisations)
    worldwide_organisations.map do |worldwide_organisation|
      link_to worldwide_organisation.name, worldwide_organisation, class: 'worldwide-organisation-link'
    end
  end
end
