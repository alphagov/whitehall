class MinisterialRolesController < PublicFacingController
  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = sorter.cabinet_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }

    @ministers_by_organisation = ministers_by_organisation
    @whips_by_organisation = whips_by_organisation
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    @policies = Policy.published.in_reverse_chronological_order.in_ministerial_role(@ministerial_role)
    set_slimmer_organisations_header(@ministerial_role.organisations)
  end

private
  def ministerial_department_type
    OrganisationType.find_by_name('Ministerial department')
  end

  def ministers_by_organisation
    Organisation.includes(ministerial_role_appointments: [:role, :person])
      .merge(RoleAppointment.current)
      .where(organisation_type_id: ministerial_department_type)
      .map do |organisation|
      [
        organisation,
        organisation.ministerial_role_appointments.select { |appointment|
          # This select is needed due to ActiveRecord not adding a `where type`
          # to the role query. Rejecting the extra objects seems nicer than
          # suffereing from n+1 queries to load in the people and roles.
          appointment.role.is_a?(MinisterialRole)
        }.map { |appointment|
          RoleAppointmentPresenter.decorate(appointment)
        }.sort_by {|role_appointment| role_appointment.role.seniority }
      ]
    end
  end

  def whips_by_organisation
    RoleAppointment.current.for_ministerial_roles.merge(Role.whip)
      .map { |appointment| RoleAppointmentPresenter.decorate(appointment) }
      .group_by {|appointment| appointment.role.whip_organisation_id }
      .map do |whip_organisation_id, role_appointments|
        [
          Whitehall::WhipOrganisation.find_by_id(whip_organisation_id),
          role_appointments.sort_by { |ra| ra.role.seniority }
        ]
    end
  end
end
