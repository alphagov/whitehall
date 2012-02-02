module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym.present?
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

  def organisation_view_all_tag(organisation, kind)
    path = send(:"#{kind}_organisation_path", @organisation)
    text = (kind == :announcements) ? "news & speeches" : kind
    content_tag(:span, safe_join(['View all', @organisation.name, link_to(text, path)], ' '), class: "view_all")
  end
end
