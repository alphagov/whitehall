slugs = %w(
  chief-driving-examiner-driving-standards-agency
  next-generation-testing-director-vehicle-and-operator-services-agency
  operations-director-vehicle-and-operator-services-agency
  scheme-management-and-external-relations-director-vehicle-and-operator-services-agency
)
roles = Role.where(slug: slugs)

RoleAppointment.where(role_id: roles.pluck(:id)).delete_all
roles.delete_all
