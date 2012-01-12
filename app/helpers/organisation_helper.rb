module OrganisationHelper
  def organisation_display_name(organisation)
    if organisation.acronym
      content_tag(:abbr, organisation.acronym, title: organisation.name)
    else
      organisation.name
    end
  end
end