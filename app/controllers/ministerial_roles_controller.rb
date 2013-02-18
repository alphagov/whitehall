class MinisterialRolesController < PublicFacingController
  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = sorter.cabinet_ministers.map { |p, r|
      [PersonPresenter.decorate(p), RolePresenter.decorate(r)]
    }
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')

    @whip_organisations = Whitehall::WhipOrganisation.all.map{|wo| [ wo, [] ]}

    @ministerial_roles_by_organisation = Organisation.includes(ministerial_role_appointments: [:role, :person]).merge(RoleAppointment.current).where(organisation_type_id: ministerial_department_type).map do |organisation|
      [
        organisation,
        organisation.ministerial_role_appointments.select { |appointment|
          # This select is needed due to ActiveRecord not adding a `where type`
          # to the role query. Rejecting the extra objects seems nicer than
          # suffereing from n+1 queries to load in the people and roles.
          if appointment.role.is_a?(MinisterialRole) && !Whitehall::WhipOrganisation.role_is_a_whip?(appointment.role)
            appointment
          elsif Whitehall::WhipOrganisation.role_is_a_whip?(appointment.role)
            @whip_organisations.each_with_index do |wo, i|
               if Whitehall::WhipOrganisation.whip_org_for_role(appointment.role).include?(wo[0])
                @whip_organisations[i][1] << RoleAppointmentPresenter.decorate(appointment)
              end
            end
            nil
          end
        }.map { |appointment|
          RoleAppointmentPresenter.decorate(appointment)
        }.sort_by {|role_appointment| role_appointment.role.seniority }
      ]
    end

    @ministerial_roles_by_whip_organisations = @whip_organisations.map {|wo| [wo[0], wo[1].sort_by {|role_appointment| role_appointment.role.seniority }]}
    @ministerial_roles_by_organisation += @ministerial_roles_by_whip_organisations
  end

  def show
    @ministerial_role = RolePresenter.decorate(MinisterialRole.find(params[:id]))
    @policies = Policy.published.in_reverse_chronological_order.in_ministerial_role(@ministerial_role)
    set_slimmer_organisations_header(@ministerial_role.organisations)
  end
end
