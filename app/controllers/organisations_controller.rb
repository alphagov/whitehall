class OrganisationsController < PublicFacingController
  include CacheControlHelper
  include Whitehall::Controllers::RolesPresenters

  enable_request_formats show: [:atom]
  before_filter :load_organisation, only: [:show, :about]
  before_filter :set_organisation_slimmer_headers, only: [:show, :about]
  skip_before_filter :set_cache_control_headers, only: [:show]
  before_filter :set_cache_max_age, only: [:show]

  def index
    @organisations = OrganisationsIndexPresenter.new(Organisation.listable.ordered_by_name_ignoring_prefix)
  end

  def show
    recently_updated_source = @organisation.published_editions.in_reverse_chronological_order
    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @announcements = latest_presenters(@organisation.published_announcements, translated: true, count: 2)
        @consultations = latest_presenters(@organisation.published_consultations, translated: true, count: 2)
        @non_statistics_publications = latest_presenters(@organisation.published_non_statistics_publications, translated: true, count: 2)
        @statistics_publications = latest_presenters(@organisation.published_statistics_publications, translated: true, count: 2)

        if @organisation.live?
          @recently_updated = recently_updated_source.with_translations(I18n.locale).limit(3)
          @feature_list = OrganisationFeatureListPresenter.new(@organisation, view_context)
          set_meta_description(@organisation.description)

          expire_on_next_scheduled_publication(@organisation.scheduled_editions)

          if @organisation.organisation_type.allowed_promotional?
            @promotional_features = PromotionalFeaturesPresenter.new(@organisation.promotional_features, view_context)
            render 'show-promotional'
          else
            @policies = latest_presenters(@organisation.published_policies, translated: true)
            @topics = @organisation.topics
            @mainstream_categories = @organisation.mainstream_categories
            @ministers = ministers
            @important_board_members = board_members.take(@organisation.important_board_members)
            @board_members = board_members.from(@organisation.important_board_members)
            @military_personnel = military_personnel
            @traffic_commissioners = traffic_commissioners
            @chief_professional_officers = chief_professional_officers
            @special_representatives = special_representatives
            @sub_organisations = @organisation.sub_organisations
            @foi_contacts = @organisation.foi_contacts
          end
        else
          render action: 'not_live'
        end
      end
      format.atom do
        @documents = EditionCollectionPresenter.new(recently_updated_source.limit(10), view_context)
      end
    end
  end

  def about
    @corporate_publications = @organisation.corporate_publications.in_reverse_chronological_order.published
  end

  private
  def ministers
    @ministerial_roles ||= filled_roles_presenter_for(@organisation, :ministerial)
    @ministerial_roles.with_unique_people
  end

  def board_members
    @board_member_roles ||= roles_presenter_for(@organisation, :management)
    @board_member_roles.with_unique_people
  end

  def traffic_commissioners
    @traffic_commissioner_roles ||= roles_presenter_for(@organisation, :traffic_commissioner)
    @traffic_commissioner_roles.with_unique_people
  end

  def military_personnel
    @military_roles ||= roles_presenter_for(@organisation, :military)
    @military_roles.with_unique_people
  end

  def chief_professional_officers
    @chief_professional_officer_roles ||= roles_presenter_for(@organisation, :chief_professional_officer)
    @chief_professional_officer_roles.with_unique_people
  end

  def special_representatives
    @special_representative_roles ||= roles_presenter_for(@organisation, :special_representative)
    @special_representative_roles.with_unique_people
  end

  def load_organisation
    @organisation = Organisation.with_translations(I18n.locale).find(params[:id])
  end

  def set_cache_max_age
    @cache_max_age = 5.minutes
  end

  def set_organisation_slimmer_headers
    set_slimmer_organisations_header([@organisation])
    set_slimmer_page_owner_header(@organisation)
  end
end
