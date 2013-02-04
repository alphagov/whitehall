class MinisterialRolesController < PublicFacingController
  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = sorter.cabinet_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')

    @ministerial_roles_by_organisation = Organisation.includes(ministerial_role_appointments: [:role, :person]).where(organisation_type_id: ministerial_department_type).map { |org|
      [org, org.ministerial_role_appointments.map { |appointment|
        RoleAppointmentPresenter.decorate(appointment)
      }]
    }
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    @policies = Policy.published.in_reverse_chronological_order.in_ministerial_role(@ministerial_role)
    set_slimmer_organisations_header(@ministerial_role.organisations)
  end
end
