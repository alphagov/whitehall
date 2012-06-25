class MinisterSorter
  def initialize(roles = MinisterialRole.includes(:current_people))
    @roles = roles
  end

  def cabinet_ministers
    ministers = roles_by_person.select { |_, roles| roles.any?(&:cabinet_member?) }
    ministers.sort_by { |person, roles|
      [roles.map(&:seniority).min, person.sort_key]
    }.map { |person, roles| [person, roles.sort_by(&:seniority)] }
  end

  def other_ministers
    ministers = roles_by_person.reject { |_, roles| roles.any?(&:cabinet_member?) }
    ministers.sort_by { |person, _|
      person.sort_key
    }.map { |person, roles| [person, roles.sort_by(&:seniority)] }
  end

private
  def expanded_roles_and_people
    @roles.map { |role|
      role.current_people.map { |person| [role, person] }
    }.flatten(1)
  end

  def roles_by_person
    expanded_roles_and_people.inject({}) { |result, (role, person)|
      (result[person] ||= []) << role
      result
    }
  end
end
