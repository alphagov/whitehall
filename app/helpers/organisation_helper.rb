module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end

  def organisation_navigation_link_to(body, path)
    link_to body, path, class: ('current' if current_organisation_navigation_path(params) == path)
  end

  def current_organisation_navigation_path(params)
    url_for params.slice(:controller, :action, :id).merge(only_path: true)
  end
end
