module CountryHelper
  def applies_to_countries_paragraph(document)
    if document.respond_to?(:countries) && document.countries.any?
      content_tag :p, "Applies to #{list_of_links_to_countries(document.countries)}.".html_safe, class: 'document-countries'
    end
  end

  def country_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_country_navigation_path(params) == path)
  end

  def current_country_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end

  def list_of_links_to_countries(countries)
    countries.map { |country| link_to country.name, country_path(country), class: "country", id: "country_#{country.id}"  }.to_sentence.html_safe
  end
end
