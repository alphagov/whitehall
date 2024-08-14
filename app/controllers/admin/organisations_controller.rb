class Admin::OrganisationsController < Admin::BaseController
  before_action :build_organisation, only: %i[new create]
  before_action :load_organisation, except: %i[index new create]
  before_action :enforce_permissions!, only: %i[new create edit update]
  before_action :build_dependencies, only: %i[new edit]
  before_action :clean_organisation_params, only: %i[create update]

  def index
    @organisations = Organisation.alphabetical
    @user_organisation = current_user.organisation
  end

  def new; end

  def create
    @organisation.assign_attributes(organisation_params)

    if @organisation.save
      redirect_to admin_organisations_path, notice: "Organisation created successfully."
    else
      build_dependencies
      render :new
    end
  end

  def show
    if @organisation.default_news_image && !@organisation.default_news_image&.all_asset_variants_uploaded?
      flash.now.notice = "#{flash[:notice]} The image is being processed. Try refreshing the page."
    end
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
                            per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
                          )

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = TopicalEvent.active
    @featurable_offsite_links = @organisation.offsite_links

    render :features
  end

  def edit; end

  def update
    delete_absent_topical_event_organisations
    if @organisation.update(organisation_params)
      redirect_to admin_organisation_path(@organisation), notice: "Organisation updated successfully."
    else
      build_dependencies
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
    return unless organisation_params &&
      organisation_params[:topical_event_organisations_attributes]

    organisation_params[:topical_event_organisations_attributes].each do |p|
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

  def build_dependencies
    build_topical_event_organisations
    @organisation.build_default_news_image if @organisation.default_news_image.blank?
    @organisation.featured_links.build if @organisation.featured_links.blank?
  end

  def clean_organisation_params
    return if organisation_params.blank?

    clean_logo_params
    clean_non_departmental_public_body_params
    clear_file_cache
  end

  def clean_logo_params
    return if organisation_params["organisation_logo_type_id"].blank? || organisation_params["organisation_logo_type_id"] == OrganisationLogoType::CustomLogo.id.to_s

    organisation_params[:logo] = nil
    organisation_params.delete(:logo_cache) if organisation_params[:logo_cache].present?
  end

  def clean_non_departmental_public_body_params
    return if organisation_params[:organisation_type_key].blank?

    type_param_is_non_departmental_public_body = OrganisationType::DATA.dig(organisation_params[:organisation_type_key].to_sym, :non_departmental_public_body)

    return if type_param_is_non_departmental_public_body

    organisation_params[:ocpa_regulated] = nil
    organisation_params[:public_meetings] = nil
    organisation_params[:public_minutes] = nil
    organisation_params[:regulatory_function] = nil
  end

  def clear_file_cache
    if organisation_params[:logo].present? && organisation_params[:logo_cache].present?
      organisation_params.delete(:logo_cache)
    end

    if organisation_params.dig(:default_news_image_attributes, :file_cache).present? && organisation_params.dig(:default_news_image_attributes, :file).present?
      organisation_params[:default_news_image_attributes].delete(:file_cache)
    end
  end
end
