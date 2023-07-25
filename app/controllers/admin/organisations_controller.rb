class Admin::OrganisationsController < Admin::BaseController
  before_action :build_organisation, only: %i[new create]
  before_action :load_organisation, except: %i[index new create]
  before_action :enforce_permissions!, only: %i[new create edit update]
  before_action :build_dependencies, only: %i[new edit]
  layout :get_layout

  def index
    @organisations = Organisation.alphabetical
    @user_organisation = current_user.organisation
    render_design_system(:index, :legacy_index)
  end

  def new
    render_design_system(:new, :legacy_new)
  end

  def create
    @organisation.assign_attributes(organisation_params)

    if @organisation.save
      publish_services_and_information_page
      redirect_to admin_organisations_path
    else
      build_dependencies
      render_design_system(:new, :legacy_new)
    end
  end

  def show
    render_design_system(:show, :legacy_show)
  end

  def features
    @feature_list = @organisation.load_or_create_feature_list(params[:locale])
    @locale = Locale.new(params[:locale] || :en)

    filtering_organisation = params[:organisation] || @organisation.id

    filter_params = params.slice(:page, :type, :author, :title)
                          .permit!
                          .to_h
                          .merge(
                            state: "published",
                            organisation: filtering_organisation,
                            per_page: preview_design_system?(next_release: false) ? Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE : nil,
                          )

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = TopicalEvent.active
    @featurable_offsite_links = @organisation.offsite_links

    if request.xhr?
      render partial: "admin/feature_lists/legacy_search_results", locals: { feature_list: @feature_list }
    else
      render_design_system(:features, :legacy_features)
    end
  end

  def edit
    render_design_system(:edit, :legacy_edit)
  end

  def update
    delete_absent_topical_event_organisations
    if @organisation.update(organisation_params)
      publish_services_and_information_page
      redirect_to admin_organisation_path(@organisation)
    else
      build_dependencies
      render_design_system(:edit, :legacy_edit)
    end
  end

  def confirm_destroy; end

  def destroy
    @organisation.destroy!
    redirect_to admin_organisations_path, notice: "Organisation deleted successfully"
  end

private

  def organisation_roles(type)
    @organisation.organisation_roles.joins(:role)
                 .merge(Role.public_send(type)).order(:ordering)
  end

  def get_layout
    design_system_actions = %w[confirm_destroy]
    design_system_actions += %w[index show features people new create edit update] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def enforce_permissions!
    case action_name
    when "new", "create"
      enforce_permission!(:create, Organisation)
    when "edit", "update"
      enforce_permission!(:edit, @organisation)
    end
  end

  def organisation_params
    @organisation_params ||= params.require(:organisation).permit(
      :name,
      :acronym,
      :logo_formatted_name,
      :organisation_logo_type_id,
      :logo,
      :logo_cache,
      :organisation_brand_colour_id,
      :url,
      :organisation_type_key,
      :alternative_format_contact_email,
      :govuk_status,
      :govuk_closed_status,
      :closed_at,
      :organisation_chart_url,
      :foi_exempt,
      :ocpa_regulated,
      :public_meetings,
      :public_minutes,
      :regulatory_function,
      :important_board_members,
      :custom_jobs_url,
      :homepage_type,
      :political,
      superseding_organisation_ids: [],
      default_news_image_attributes: %i[file file_cache id],
      organisation_roles_attributes: %i[id ordering],
      parent_organisation_ids: [],
      topical_event_organisations_attributes: %i[topical_event_id ordering id _destroy],
      featured_links_attributes: %i[title url _destroy id],
    )
  end

  def build_topical_event_organisations
    n = @organisation.topical_event_organisations.count
    @organisation.topical_event_organisations.each.with_index do |ot, i|
      ot.ordering = i
    end
    (n...13).each do |i|
      @organisation.topical_event_organisations.build(ordering: i)
    end
  end

  def delete_absent_topical_event_organisations
    return unless params[:organisation] &&
      params[:organisation][:topical_event_organisations_attributes]

    params[:organisation][:topical_event_organisations_attributes].each do |p|
      if p[:topical_event_id].blank?
        p["_destroy"] = true
      end
    end
  end

  def build_organisation
    @organisation = Organisation.new
  end

  def load_organisation
    @organisation = Organisation.friendly.find(params[:id])
  end

  def publish_services_and_information_page
    Whitehall::PublishingApi.publish_services_and_information_async(@organisation.id)
  end

  def build_dependencies
    build_topical_event_organisations
    @organisation.build_default_news_image if @organisation.default_news_image.blank?
    @organisation.featured_links.build if @organisation.featured_links.blank?
  end
end
