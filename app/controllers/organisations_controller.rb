class OrganisationsController < PublicFacingController
  include CacheControlHelper

  before_filter :load_organisation, only: [:show, :about]
  skip_before_filter :set_cache_control_headers, only: [:show]
  before_filter :set_cache_max_age, only: [:show]

  def index
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    non_ministerial_department_type = OrganisationType.find_by_name('Non-ministerial department')
    public_corporation_type = OrganisationType.find_by_name('Public corporation')

    @ministerial_departments = Organisation.where(organisation_type_id: ministerial_department_type).all(include: [:organisation_type, { child_organisations: :organisation_type}])

    @public_corporations = Organisation.where(organisation_type_id: public_corporation_type)
    @non_ministerial_departments = Organisation.where(organisation_type_id: non_ministerial_department_type)

    @agencies_and_government_bodies = Organisation.where('organisation_type_id NOT IN (?)', [
      ministerial_department_type, non_ministerial_department_type, public_corporation_type
    ] + OrganisationType.unlistable).ordered_by_name_ignoring_prefix
  end

  def show
    recently_updated_source = @organisation.published_editions.in_reverse_chronological_order
    expires_in 5.minutes, public: true
    respond_to do |format|
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10))
      end
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        if @organisation.live?
          @featured_editions = FeaturedEditionPresenter.decorate(@organisation.featured_edition_organisations.limit(6))
          @policies = PolicyPresenter.decorate(@organisation.published_policies.in_reverse_chronological_order.limit(3))
          @topics = @organisation.topics_with_content
          @non_statistics_publications = PublicationesquePresenter.decorate(@organisation.published_non_statistics_publications.in_reverse_chronological_order.limit(2))
          @statistics_publications = PublicationesquePresenter.decorate(@organisation.published_statistics_publications.in_reverse_chronological_order.limit(2))
          @consultations = PublicationesquePresenter.decorate(@organisation.published_consultations.in_reverse_chronological_order.limit(2))
          @announcements = AnnouncementPresenter.decorate(@organisation.published_announcements.in_reverse_chronological_order.limit(2))
          @ministers = ministers
          @important_board_members = board_members.take(@organisation.important_board_members)
          @board_members = board_members.from(@organisation.important_board_members)
          @military_personnel = military_personnel
          @traffic_commissioners = traffic_commissioners
          @special_representatives = special_representatives
          @sub_organisations = @organisation.sub_organisations
          set_slimmer_organisations_header([@organisation])
          expire_on_next_scheduled_publication(@organisation.scheduled_editions)
        else
          render action: 'external'
        end
      end
    end
  end

  def about
    @corporate_publications = @organisation.corporate_publications.in_reverse_chronological_order.published
  end

  private

  def ministers
    @ministerial_roles ||= filled_roles_presenter_for(:ministerial)
    @ministerial_roles.with_unique_people
  end

  def board_members
    @board_member_roles ||= roles_presenter_for(:management)
    @board_member_roles.with_unique_people
  end

  def traffic_commissioners
    @traffic_commissioner_roles ||= roles_presenter_for(:traffic_commissioner)
    @traffic_commissioner_roles.with_unique_people
  end

  def military_personnel
    @military_roles ||= roles_presenter_for(:military)
    @military_roles.with_unique_people
  end

  def special_representatives
    @special_representative_roles ||= roles_presenter_for(:special_representative)
    @special_representative_roles.with_unique_people
  end

  def filled_roles_presenter_for(association)
    roles_presenter = roles_presenter_for(association)
    roles_presenter.remove_unfilled_roles!
    roles_presenter
  end

  def roles_presenter_for(association)
    RolesPresenter.new(@organisation.send("#{association}_roles").order("organisation_roles.ordering"))
  end

  def load_organisation
    @organisation = Organisation.with_translations(I18n.locale).find(params[:id])
  end

  def set_cache_max_age
    @cache_max_age = 5.minutes
  end
end
