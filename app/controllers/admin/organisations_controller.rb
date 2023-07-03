class Admin::OrganisationsController < Admin::BaseController
  before_action :load_organisation, except: %i[index new create]
  before_action :enforce_permissions!, only: %i[new create edit update reorder_people order_people]
  layout :get_layout

  def index
    @organisations = Organisation.alphabetical
    @user_organisation = current_user.organisation
    render_design_system(:index, :legacy_index)
  end

  def new
    @organisation = Organisation.new
    build_topical_event_organisations
  end

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      publish_services_and_information_page
      redirect_to admin_organisations_path
    else
      render :new
    end
  end

  def show
    render_design_system(:show, :legacy_show)
  end

  def people
    @render_reorder = can?(:edit, @organisation)
    @ministerial_organisation_roles = organisation_roles(:ministerial)
    @management_organisation_roles = organisation_roles(:management)
    @traffic_commissioner_organisation_roles = organisation_roles(:traffic_commissioner)
    @military_organisation_roles = organisation_roles(:military)
    @special_representative_organisation_roles = organisation_roles(:special_representative)
    @chief_professional_officer_roles = organisation_roles(:chief_professional_officer)
    render_design_system(:people, :legacy_people)
  end

  def reorder_people
    type = params[:type]
    @organisation_roles = organisation_roles(type)
  end

  def order_people
    params[:ordering].each do |organisation_role_id, ordering|
      @organisation.organisation_roles.find(organisation_role_id).update_column(:ordering, ordering)
    end

    redirect_to people_admin_organisation_path(@organisation), notice: "#{params[:type].capitalize.gsub("_", " ")} roles re-ordered"
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
    build_topical_event_organisations
    build_default_news_image
  end

  def update
    delete_absent_topical_event_organisations
    if @organisation.update(organisation_params)
      publish_services_and_information_page
      redirect_to admin_organisation_path(@organisation)
    else
      render :edit
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
    design_system_actions += %w[index show features people reorder_people order_people] if preview_design_system?(next_release: false)

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
    when "reorder_people"
      enforce_permission!(:reorder_people, @organisation)
    when "order_people"
      enforce_permission!(:order_people, @organisation)
    end
  end

  def organisation_params
    params.require(:organisation).permit(
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
      default_news_image_attributes: %i[file file_cache],
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

  def build_default_news_image
    @organisation.build_default_news_image
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

  def load_organisation
    @organisation = Organisation.friendly.find(params[:id])
  end

  def publish_services_and_information_page
    Whitehall::PublishingApi.publish_services_and_information_async(@organisation.id)
  end
end
