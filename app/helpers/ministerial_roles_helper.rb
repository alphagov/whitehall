module MinisterialRolesHelper
  def ministerial_role_organisation_class(ministerial_role)
    if ministerial_role.organisations.size == 1
      ministerial_role.organisations.first.slug
    else
      'multiple_organisations'
    end
  end

  def array_of_links_to_ministers(ministers)
    ministers.map do |minister|
      link_to minister.current_person_name(minister.name), minister
    end
  end

  def policies_responsible(person, role)
    if person.present?
      t('roles.policies_responsible_with_person', person: person.name, role: role.name)
    else
      t('roles.policies_responsible', role: role.name)
    end
  end
end
