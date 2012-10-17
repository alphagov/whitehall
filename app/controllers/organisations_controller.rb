class OrganisationsController < PublicFacingController
  before_filter :load_organisation,
    only: [:show, :about, :consultations, :ministers, :management_team, :chiefs_of_staff]

  def index
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    @ministerial_departments = Organisation.where(organisation_type_id: ministerial_department_type).all(include: [:organisation_type, { child_organisations: :organisation_type}])
    @all_other_organisations = Organisation.where('organisation_type_id != ?', ministerial_department_type.id).ordered_by_name_ignoring_prefix
  end

  def alphabetical
    @organisations = Organisation.ordered_by_name_ignoring_prefix
  end

  def show
    @recently_updated = @organisation.published_editions.by_published_at.limit(3)
    if @organisation.live?
      @news_articles = NewsArticle.published.in_organisation(@organisation)
      @featured_editions = FeaturedEditionPresenter.decorate(@organisation.featured_edition_organisations.limit(6))
      @top_military_role = @organisation.top_military_role && RolePresenter.decorate(@organisation.top_military_role)
      @policies = PolicyPresenter.decorate(@organisation.published_policies.by_published_at.limit(3))
      @topics = @organisation.topics_with_content
      @publications = PublicationesquePresenter.decorate(@organisation.published_publications.by_published_at.limit(3))
      @announcements = @organisation.published_announcements.by_first_published_at.limit(3)
      @ministers = ministers
      @civil_servants = civil_servants
    else
      render action: 'external'
    end
  end

  def about
    @corporate_publications = @organisation.corporate_publications.published
  end

  def consultations
    @consultations = Consultation.in_organisation(@organisation).published.by_published_at
  end

  def chiefs_of_staff
  end

  private

  def ministers
    @ministerial_roles = @organisation.ministerial_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def civil_servants
    @civil_servant_roles = @organisation.board_member_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end
