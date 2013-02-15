module CountryHelper
  def world_location_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_world_location_navigation_path(params) == path)
  end

  def current_world_location_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def list_of_links_to_world_locations_once_world_goes_live(world_locations)
    # Once world goes live, return a list of links rather than spans
    world_locations.map { |world_location|
      content_tag_for(:span, world_location) { world_location.name }
    }.to_sentence.html_safe
  end

  def list_of_links_to_worldwide_offices_once_world_goes_live(worldwide_offices)
    # Once world goes live, return a list of links rather than spans
    worldwide_offices.map { |worldwide_office|
      content_tag_for(:span, worldwide_office) { worldwide_office.name }
    }.to_sentence.html_safe
  end
end
