class OrganisationsController < PublicFacingController
  include CacheControlHelper

  enable_request_formats show: [:atom]
  before_action :load_organisation, only: [:show]
  before_action :set_organisation_slimmer_headers, only: [:show]
  skip_before_action :set_cache_control_headers, only: [:show]
  before_action :set_cache_max_age, only: [:show]

  def index
    @content_item = Whitehall.content_store.content_item("/government/organisations")

    if params[:courts_only]
      @courts = Organisation.courts.listable.ordered_by_name_ignoring_prefix
      @hmcts_tribunals = Organisation.hmcts_tribunals.listable.ordered_by_name_ignoring_prefix
      render :courts_index
    else
      @organisations = OrganisationsIndexPresenter.new(
        Organisation.excluding_courts_and_tribunals.listable.ordered_by_name_ignoring_prefix)
      set_meta_description("What's the latest from a department, agency or public body?")
      render :index
    end
  end

  def show
    @content_item = Whitehall.content_store.content_item(@organisation.base_path)

    recently_updated_source = @organisation.published_non_corporate_information_pages.in_reverse_chronological_order
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
          @policies = featured_policies
          set_meta_description(@organisation.summary)

          expire_on_next_scheduled_publication(@organisation.scheduled_editions)

          if @organisation.organisation_type.allowed_promotional?
            @promotional_features = PromotionalFeaturesPresenter.new(@organisation.promotional_features, view_context)
            render 'show-promotional'
          else
            @topics = @organisation.topics
            @ministers = ministers
            @important_board_members = board_members.take(@organisation.important_board_members)
            @board_members = board_members.from(@organisation.important_board_members)
            @military_personnel = military_personnel
            @traffic_commissioners = traffic_commissioners
            @chief_professional_officers = chief_professional_officers
            @special_representatives = special_representatives
            @judges = params[:courts_only] ? [] : judges
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

  def judges
    @judge_roles ||= roles_presenter_for(@organisation, :judge)
    @judge_roles.with_unique_people
  end

  def featured_policies
    @featured_policies ||= FeaturedPoliciesPresenter.new(
      @organisation.featured_policies.order('ordering').limit(5),
      links_for_featured_policies
    )
  end

  def links_for_featured_policies
    return unless organisation_content
    organisation_content["links"].try(:[], "featured_policies")
  end

  def filled_roles_presenter_for(organisation, association)
    roles_presenter = roles_presenter_for(organisation, association)
    roles_presenter.remove_unfilled_roles!
    roles_presenter
  end

  def roles_presenter_for(organisation, association)
    roles = organisation.send("#{association}_roles").
                         with_translations.
                         includes(:current_people).
                         order("organisation_roles.ordering")
    RolesPresenter.new(roles, view_context)
  end

  def load_organisation
    @organisation = Organisation.with_translations(I18n.locale).find(params[:id])
    if params[:courts_only]
      raise ActiveRecord::RecordNotFound if !@organisation.court_or_hmcts_tribunal?
    else
      raise ActiveRecord::RecordNotFound if @organisation.court_or_hmcts_tribunal?
    end
  end

  def organisation_content
    @organisation_content ||= begin
                                path = Whitehall.url_maker.organisation_path(@organisation)
                                Whitehall.content_store.content_item(path)
                              rescue GdsApi::ContentStore::ItemNotFound
                                :content_not_found
                              end
    @organisation_content != :content_not_found ? @organisation_content : nil
  end

  def set_cache_max_age
    @cache_max_age = 5.minutes
  end

  def set_organisation_slimmer_headers
    set_slimmer_organisations_header([@organisation])
    set_slimmer_page_owner_header(@organisation)
  end
end
