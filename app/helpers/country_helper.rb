module CountryHelper
  def country_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_country_navigation_path(params) == path)
  end

  def current_country_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def list_of_links_to_countries_once_world_goes_live(countries)
    # Once world goes live, return a list of links rather than spans
    countries.map { |country| content_tag :span, country.name, class: "country", id: "country_#{country.id}"  }.to_sentence.html_safe
  end

  def list_of_links_to_statistical_data_sets(data_sets)
    data_sets.map { |data_set| link_to data_set.title, public_document_path(data_set) }.to_sentence.html_safe
  end
end
