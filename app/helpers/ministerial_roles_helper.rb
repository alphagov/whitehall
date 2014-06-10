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
      link_to minister.current_person_name, minister, class: 'minister-link'
    end
  end

  def policies_responsible(person, role)
    if person.present?
      t('roles.policies_responsible_with_person', person: person.name, role: role.name)
    else
      t('roles.policies_responsible', role: role.name)
    end
  end

  def role_status_text(role)
    case role.status
    when 'no_longer_exists'
      if role.date_of_inactivity.present?
        "#{role.name} no longer exists as of #{role.date_of_inactivity.to_s(:one_month_precision)}".html_safe
      else
        "#{role.name} no longer exists"
      end
    when "replaced"
      if role.date_of_inactivity.present?
        "#{role.name} was replaced by #{superseding_roles_text(role)} in #{role.date_of_inactivity.to_s(:one_month_precision)}".html_safe
      else
        "#{role.name} was replaced by #{superseding_roles_text(role)}"
      end
    when "split"
      if role.date_of_inactivity.present?
        "#{role.name} was split into #{superseding_roles_text(role)} in #{role.date_of_inactivity.to_s(:one_month_precision)}".html_safe
      else
        "#{role.name} was split into #{superseding_roles_text(role)}"
      end
    when "merged"
      if role.date_of_inactivity.present?
        "#{role.name} was merged into #{superseding_roles_text(role)} in #{role.date_of_inactivity.to_s(:one_month_precision)}".html_safe
      else
        "#{role.name} was merged into #{superseding_roles_text(role)}"
      end
    when "active"
      unless role.occupied?
        "This is not a current government role"
      end
    end
  end

private

  def superseding_roles_text(role)
    if role.superseding_roles.any?
      role_links = role.superseding_roles.map { |role|
        role.ministerial? ? link_to(role.name, polymorphic_path(role)) : role.name
      }
      role_links.to_sentence.html_safe
    end
  end
end
