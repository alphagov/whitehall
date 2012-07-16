module CountryHelper
  def country_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_country_navigation_path(params) == path)
  end

  def current_country_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def list_of_links_to_countries(countries)
    countries.map { |country| link_to country.name, country_path(country), class: "country"  }.to_sentence.html_safe
  end

  def list_of_links_to_inapplicable_nations(inapplicable_nations)
    inapplicable_nations.map { |nation| link_to nation.nation.name, nation.alternative_url, class: "country", rel: "external"  }.to_sentence.html_safe
  end
end
