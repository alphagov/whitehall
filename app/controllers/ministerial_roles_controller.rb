class MinisterialRolesController < PublicFacingController
  include Whitehall::Controllers::RolesPresenters

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
    Organisation.where(organisation_type_id: ministerial_department_type).includes(:translations).map do |organisation|
      roles_presenter = filled_roles_presenter_for(organisation, :ministerial)
      [ organisation, roles_presenter ]
    end
  end

  def whips_by_organisation
    Role.includes(:translations, :current_people).whip.group_by(&:whip_organisation_id).map do |whip_organisation_id, roles|
      presenter = RolesPresenter.new(roles.sort_by(&:seniority))
      presenter.remove_unfilled_roles!
      [
        Whitehall::WhipOrganisation.find_by_id(whip_organisation_id),
        presenter
      ]
    end.sort_by { |org, whips| org.sort_order }
  end
end
