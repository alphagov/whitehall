class MinisterialRolesController < PublicFacingController
  include Whitehall::Controllers::RolesPresenters

  enable_request_formats show: [:atom]

  def index
    sorter = MinisterSorter.new
    @cabinet_ministerial_roles = decorated_people_and_their_roles(sorter.cabinet_ministers)
    reshuffle_setting = load_reshuffle_setting
    if reshuffle_setting
      @is_during_reshuffle = reshuffle_setting.on
      @reshuffle_messaging = reshuffle_setting.govspeak
    end

    cabinet_roles = MinisterSorter.new(Role.with_translations.includes(:current_people)).also_attends_cabinet
    @also_attends_cabinet = decorated_people_and_their_roles(cabinet_roles)
    @ministers_by_organisation = ministers_by_organisation
    @whips_by_organisation = whips_by_organisation
  end

  def show
    @ministerial_role = RolePresenter.new(MinisterialRole.find(params[:id]), view_context)
    @policies = decorate_collection(@ministerial_role.policies.published.in_reverse_chronological_order, PolicyPresenter)
    set_slimmer_organisations_header(@ministerial_role.organisations)
    set_slimmer_page_owner_header(@ministerial_role.organisations.first)
  end

private
  def decorated_people_and_their_roles(people_and_roles)
    people_and_roles.map do |person, roles|
      [
        PersonPresenter.new(person, view_context),
        roles.map { |r| RolePresenter.new(r, view_context) }
      ]
    end
  end

  def ministers_by_organisation
    Organisation.ministerial_departments
		 .with_translations
		 .with_translations_for(:ministerial_roles)
		 .includes(ministerial_roles: [:current_people])
		 .order('organisation_roles.ordering').map do |organisation|
      roles_presenter = RolesPresenter.new(organisation.ministerial_roles, view_context)
      roles_presenter.remove_unfilled_roles!
      [organisation, roles_presenter]
    end
  end

  def whips_by_organisation
    Role.with_translations.includes(:current_people).whip.group_by(&:whip_organisation_id).map do |whip_organisation_id, roles|
      roles_presenter = RolesPresenter.new(roles.sort_by(&:whip_ordering), view_context)
      roles_presenter.remove_unfilled_roles!
      [Whitehall::WhipOrganisation.find_by_id(whip_organisation_id), roles_presenter]
    end.sort_by { |org, _| org.sort_order }
  end
end
