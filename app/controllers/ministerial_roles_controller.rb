class MinisterialRolesController < PublicFacingController
  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = sorter.cabinet_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')

    @ministerial_roles_by_organisation = Organisation.includes(ministerial_role_appointments: [:role, :person]).where(organisation_type_id: ministerial_department_type).map do |organisation|
      [
        organisation,
        organisation.ministerial_role_appointments.select { |appointment|
          # This select is needed due to ActiveRecord not adding a `where type`
          # to the role query. Rejecting the extra objects seems nicer than
          # suffereing from n+1 queries to load in the people and roles.
          appointment.role.is_a?(MinisterialRole) && appointment.current?
        }.map { |appointment|
          RoleAppointmentPresenter.decorate(appointment)
        }.sort_by {|role_appointment| role_appointment.role.seniority }
      ]
    end
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    @policies = Policy.published.in_reverse_chronological_order.in_ministerial_role(@ministerial_role)
    set_slimmer_organisations_header(@ministerial_role.organisations)
  end
end
