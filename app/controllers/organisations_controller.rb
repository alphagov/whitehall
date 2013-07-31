class OrganisationsController < PublicFacingController
  include CacheControlHelper
  include Whitehall::Controllers::RolesPresenters

  before_filter :load_organisation, only: [:show, :about]
  skip_before_filter :set_cache_control_headers, only: [:show]
  before_filter :set_cache_max_age, only: [:show]

  def index
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    non_ministerial_department_type = OrganisationType.find_by_name('Non-ministerial department')
    public_corporation_type = OrganisationType.find_by_name('Public corporation')
    executive_office_type = OrganisationType.find_by_name('Executive office')

    @executive_offices = Organisation.where(organisation_type_id: executive_office_type).with_translations.includes(:organisation_type)
    @ministerial_departments = Organisation.where(organisation_type_id: ministerial_department_type).alphabetical.includes(:organisation_type)

    @public_corporations = Organisation.where(organisation_type_id: public_corporation_type).alphabetical.includes(:organisation_type)
    @non_ministerial_departments = Organisation.where(organisation_type_id: non_ministerial_department_type).alphabetical.includes(:organisation_type)

    @agencies_and_government_bodies = Organisation.where('organisation_type_id NOT IN (?)', [
      ministerial_department_type, non_ministerial_department_type,
      public_corporation_type, executive_office_type
    ] + OrganisationType.unlistable).with_translations.includes(:organisation_type).ordered_by_name_ignoring_prefix
  end

  def show
    recently_updated_source = @organisation.published_editions.in_reverse_chronological_order
    set_expiry 5.minutes
    respond_to do |format|
      format.html do
        @recently_updated = recently_updated_source.limit(3)
        if @organisation.live?
          @feature_list = OrganisationFeatureListPresenter.new(@organisation, view_context)
          set_slimmer_organisations_header([@organisation])
          set_slimmer_page_owner_header(@organisation)
          set_meta_description(@organisation.description)

          expire_on_next_scheduled_publication(@organisation.scheduled_editions)

          if @organisation.organisation_type.executive_office?
            @promotional_features = PromotionalFeaturesPresenter.new(@organisation.promotional_features, view_context)
            render 'show-executive-office'
          else
            @policies = decorate_collection(@organisation.published_policies.in_reverse_chronological_order.limit(3), PolicyPresenter)
            @topics = @organisation.topics_with_content
            @mainstream_categories = @organisation.mainstream_categories
            @non_statistics_publications = decorate_collection(@organisation.published_non_statistics_publications.in_reverse_chronological_order.limit(2), PublicationesquePresenter)
            @statistics_publications = decorate_collection(@organisation.published_statistics_publications.in_reverse_chronological_order.limit(2), PublicationesquePresenter)
            @consultations = decorate_collection(@organisation.published_consultations.in_reverse_chronological_order.limit(2), PublicationesquePresenter)
            @announcements = decorate_collection(@organisation.published_announcements.in_reverse_chronological_order.limit(2), AnnouncementPresenter)
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
end
