module CountryHelper
  def country_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_country_navigation_path(params) == path)
  end

  def current_country_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def list_of_links_to_countries(countries)
    countries.map { |country| link_to country.nation.name, country.alternative_url, class: "country"  }.to_sentence.html_safe
  end
end
