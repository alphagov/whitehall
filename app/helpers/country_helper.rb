module CountryHelper
  def world_location_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_world_location_navigation_path(params) == path)
  end

  def current_world_location_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def array_of_links_to_world_locations(world_locations)
    world_locations.map { |world_location|
      if Whitehall.world_feature?
        link_to(world_location.name, world_location, class: dom_class(world_location), id: dom_id(world_location))
      else
        content_tag_for(:span, world_location) { world_location.name }
      end
    }
  end

  def array_of_links_to_worldwide_organisations(worldwide_organisations)
    worldwide_organisations.map { |worldwide_organisation|
      if Whitehall.world_feature?
        link_to(worldwide_organisation.name, worldwide_organisation, class: dom_class(worldwide_organisation), id: dom_id(worldwide_organisation))
      else
        content_tag_for(:span, worldwide_organisation) { worldwide_organisation.name }
      end
    }
  end
end
