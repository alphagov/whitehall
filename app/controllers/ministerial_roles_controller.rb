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
    Organisation.where(organisation_type_id: ministerial_department_type).map do |organisation|
      presenter = RolesPresenter.new(organisation.ministerial_roles.order("organisation_roles.ordering").sort_by(&:seniority))
      presenter.remove_unfilled_roles!
      [ organisation, presenter ]
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
    end.sort_by { |org, whips| org.sort_order }
  end
end
