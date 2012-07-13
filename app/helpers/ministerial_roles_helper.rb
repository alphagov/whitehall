module MinisterialRolesHelper
  def ministerial_role_organisation_class(ministerial_role)
    if ministerial_role.organisations.size == 1
      ministerial_role.organisations.first.slug
    else
      'multiple_organisations'
    end
  end

  def list_of_links_to_ministers(ministers)
    ministers.map { |minister| link_to minister.current_person_name, minister, class: "minister" }.to_sentence.html_safe
  end
end