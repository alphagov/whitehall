class OrganisationsController < PublicFacingController
  include CacheControlHelper

  before_filter :load_organisation, only: [:show, :about]

  def index
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    @ministerial_departments = Organisation.where(organisation_type_id: ministerial_department_type).all(include: [:organisation_type, { child_organisations: :organisation_type}])
    @all_other_organisations = Organisation.where('organisation_type_id != ?', ministerial_department_type.id).ordered_by_name_ignoring_prefix
  end

  def show
    @recently_updated = @organisation.published_editions.by_published_at.limit(3)
    if @organisation.live?
      @featured_editions = FeaturedEditionPresenter.decorate(@organisation.featured_edition_organisations.limit(6))
      @top_military_role = @organisation.top_military_role && RolePresenter.decorate(@organisation.top_military_role)
      @policies = PolicyPresenter.decorate(@organisation.published_policies.in_reverse_chronological_order.limit(3))
      @topics = @organisation.topics_with_content
      @publications = PublicationesquePresenter.decorate(@organisation.published_publications.in_reverse_chronological_order.limit(3))
      @announcements = AnnouncementPresenter.decorate(@organisation.published_announcements.in_reverse_chronological_order.limit(3))
      @ministers = ministers
      @civil_servants = civil_servants
      @traffic_commissioners = traffic_commissioners
      @special_representatives = special_representatives
      set_slimmer_organisations_header([@organisation])
      expire_on_next_scheduled_publication(@organisation.scheduled_editions)
    else
      render action: 'external'
    end
  end

  def about
    @corporate_publications = @organisation.corporate_publications.published
  end

  private

  def ministers
    @ministerial_roles = @organisation.ministerial_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role) if role.current_person
    end.compact
  end

  def civil_servants
    @civil_servant_roles = @organisation.board_member_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def traffic_commissioners
    @traffic_commissioner_roles = @organisation.traffic_commissioner_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def special_representatives
    @organisation.special_representative_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end
