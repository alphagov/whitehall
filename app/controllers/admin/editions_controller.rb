class Admin::EditionsController < Admin::BaseController
  before_filter :remove_blank_parameters
  before_filter :clean_edition_parameters, only: [:create, :update]
  before_filter :clear_scheduled_publication_if_not_activated, only: [:create, :update]
  before_filter :find_edition, only: [:show, :edit, :update, :submit, :revise, :diff, :reject, :destroy, :topics]
  before_filter :prevent_modification_of_unmodifiable_edition, only: [:edit, :update]
  before_filter :delete_absent_edition_organisations, only: [:create, :update]
  before_filter :build_edition, only: [:new, :create]
  before_filter :build_edition_organisations, only: [:new, :edit]
  before_filter :detect_other_active_editors, only: [:edit]
  before_filter :set_default_edition_locations, only: :new
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!, only: [:show, :edit, :update, :submit, :revise, :diff, :reject, :destroy]
  before_filter :redirect_to_controller_for_type, only: [:show]
  before_filter :deduplicate_specialist_sectors, only: [:create, :update]

  def enforce_permissions!
    case action_name
    when 'index'
      enforce_permission!(:see, edition_class || Edition)
    when 'show', 'topics'
      enforce_permission!(:see, @edition)
    when 'new'
      enforce_permission!(:create, edition_class || Edition)
    when 'create'
      enforce_permission!(:create, @edition)
    when 'edit', 'update', 'revise', 'diff'
      enforce_permission!(:update, @edition)
    when 'destroy'
      enforce_permission!(:delete, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction.new(action_name)
    end
  end

  def index
    if filter && filter.valid?
      session[:document_filters] = params_filters
      if request.xhr?
        render partial: 'search_results'
      else
        render :index
      end
    elsif session_filters.any?
      redirect_to session_filters
    else
      redirect_to default_filters
    end
  end

  def show
    fetch_version_and_remark_trails
  end

  def new
  end

  def create
    if @edition.save
      redirect_to show_or_edit_path, saved_confirmation_notice
    else
      flash.now[:alert] = "There are some problems with the document"
      extract_edition_information_from_errors
      build_edition_dependencies
      render action: "new"
    end
  end

  def edit
    @edition.open_for_editing_as(current_user)
    fetch_version_and_remark_trails
    render :edit
  end

  def update
    if @edition.edit_as(current_user, edition_params)
      @edition.convert_to_draft! if params[:speed_save_convert]
      redirect_to after_update_path, saved_confirmation_notice
    else
      flash.now[:alert] = "There are some problems with the document"
      if speed_tagging?
        render :show
      else
        extract_edition_information_from_errors
        build_edition_dependencies
        fetch_version_and_remark_trails
        render :edit
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    build_edition_dependencies
    render action: "edit"
  end

  def revise
    new_draft = @edition.create_draft(current_user)
    if new_draft.persisted?
      redirect_to edit_admin_edition_path(new_draft)
    else
      redirect_to edit_admin_edition_path(@edition.document.latest_edition),
        alert: new_draft.errors.full_messages.to_sentence
    end
  end

  def diff
    audit_trail_entry = edition_class.find(params[:audit_trail_entry_id])
    @audit_trail_entry = LocalisedModel.new(audit_trail_entry, audit_trail_entry.locale)
  end

  def destroy
    edition_deleter = Whitehall.edition_services.deleter(@edition)
    if edition_deleter.perform!
      redirect_to admin_editions_path, notice: "The document '#{@edition.title}' has been deleted"
    else
      redirect_to admin_edition_path(@edition), alert: edition_deleter.failure_reason
    end
  end

  private

  def speed_tagging?
    params[:speed_save_convert] || params[:speed_save_next] || params[:speed_save]
  end

  def after_update_path
    # infer the next action the user wants to take
    # from the button they pressed to submit the form
    if params[:speed_save_convert] || params[:speed_save_next]
      next_imported_document_path
    else
      show_or_edit_path
    end
  end

  def next_imported_document_path
    import = Import.source_of(@edition.document)
    next_document = import.document_imported_after(@edition.document) if import
    return admin_edition_path(next_document.latest_edition) if next_document

    admin_editions_path(session_filters.merge(state: :imported))
  end

  def fetch_version_and_remark_trails
    @edition_remarks = @edition.document_remarks_trail.reverse
    @edition_history = Kaminari.paginate_array(@edition.document_version_trail.reverse).page(params[:page]).per(30)
  end

  def edition_class
    Edition
  end

  def edition_params
    params.fetch(:edition, {}).permit(
      :title, :body, :change_note, :summary, :first_published_at,
      :publication_type_id, :scheduled_publication, :lock_version,
      :access_limited, :alternative_format_provider_id, :opening_at,
      :closing_at, :external, :external_url, :minor_change,
      :roll_call_introduction, :operational_field_id, :news_article_type_id,
      :relevant_to_local_government, :role_appointment_id, :speech_type_id,
      :delivered_on, :location, :person_override, :locale,
      :primary_mainstream_category_id, :related_mainstream_content_url,
      :related_mainstream_content_title,
      :additional_related_mainstream_content_url,
      :additional_related_mainstream_content_title,
      :primary_specialist_sector_tag,
      secondary_specialist_sector_tags: [],
      ministerial_role_ids: [],
      lead_organisation_ids: [],
      supporting_organisation_ids: [],
      organisation_ids: [],
      world_location_ids: [],
      worldwide_organisation_ids: [],
      worldwide_priority_ids: [],
      related_policy_ids: [],
      other_mainstream_category_ids: [],
      topic_ids: [],
      topical_event_ids: [],
      outbound_related_document_ids: [],
      role_appointment_ids: [],
      statistical_data_set_document_ids: [],
      policy_team_ids: [],
      policy_advisory_group_ids: [],
      document_collection_group_ids: [],
      images_attributes: [
        :id, :alt_text, :caption, :_destroy,
        image_data_attributes: [:file, :file_cache]
      ],
      consultation_participation_attributes: [
        :id, :link_url, :email, :postal_address,
        consultation_response_form_attributes: [
          :id, :title, :_destroy,
          consultation_response_form_data_attributes: [:id, :file, :file_cache]
        ]
      ],
      nation_inapplicabilities_attributes: [
        :id, :nation_id, :alternative_url, :excluded
      ],
      fatality_notice_casualties_attributes: [:personal_details, :_destroy]
    )
  end

  def new_edition_params
    edition_params.merge(creator: current_user)
  end

  def show_or_edit_path
    if params[:save_and_continue].present?
      [:edit, :admin, @edition]
    else
      admin_edition_url(@edition)
    end
  end

  def saved_confirmation_notice
    { notice: "The document has been saved" }
  end

  def build_edition
    edition_locale = edition_params[:locale] || I18n.default_locale
    I18n.with_locale(edition_locale) do
      @edition = LocalisedModel.new(edition_class.new(new_edition_params), edition_locale)
    end
  end

  def find_edition
    edition = edition_class.find(params[:id])
    @edition = LocalisedModel.new(edition, edition.locale)
  end

  def extract_edition_information_from_errors
    information = @edition.errors.delete(:information)
    @information = information ? information.first : nil
  end

  def build_edition_dependencies
    build_image
    build_edition_organisations
  end

  def build_edition_organisations
    return unless @edition.can_be_related_to_organisations?

    n = @edition.edition_organisations.select { |eo| eo.lead? }.count
    (n...4).each do |i|
      if i == 0 && current_user.organisation
        @edition.edition_organisations.build(lead_ordering: i, lead: true, organisation: current_user.organisation)
      else
        @edition.edition_organisations.build(lead_ordering: i, lead: true)
      end
    end
    n = @edition.edition_organisations.reject { |eo| eo.lead? }.count
    (n...6).each do |i|
      @edition.edition_organisations.build(lead: false)
    end
  end

  def set_default_edition_locations
    if current_user.world_locations.any? && !@edition.world_locations.any?
      @edition.world_locations = current_user.world_locations
    end
  end

  def delete_absent_edition_organisations
    return unless params[:edition]
    if params[:edition][:lead_organisation_ids]
      params[:edition][:lead_organisation_ids] = params[:edition][:lead_organisation_ids].reject(&:blank?)
    end
    if params[:edition][:supporting_organisation_ids]
      params[:edition][:supporting_organisation_ids] = params[:edition][:supporting_organisation_ids].reject(&:blank?)
    end
  end

  def build_image
    return unless @edition.allows_image_attachments?

    unless @edition.images.any?(&:new_record?)
      image = @edition.images.build
      image.build_image_data
    end
  end

  def default_filters
    {organisation: current_user.organisation.try(:id), state: :active}
  end

  def session_filters
    session[:document_filters] || {}
  end

  def params_filters
    params.slice(:type, :state, :organisation, :author, :page, :title, :world_location, :from_date, :to_date)
  end

  def params_filters_with_default_state
    params_filters.reverse_merge(state: 'active')
  end

  def filter
    @filter ||= Admin::EditionFilter.new(edition_class, current_user, params_filters_with_default_state) if params_filters.any?
  end

  def detect_other_active_editors
    RecentEditionOpening.expunge! if rand(10) == 0
    @recent_openings = @edition.active_edition_openings.except_editor(current_user)
  end

  def remove_blank_parameters
    params.reject! { |_, value| value.blank? }
  end

  def clean_edition_parameters
    params[:edition][:title].strip! if params[:edition] && params[:edition][:title]
    params[:edition].delete(:locale) if params[:edition] && params[:edition][:locale].blank?
  end

  def clear_scheduled_publication_if_not_activated
    if params[:scheduled_publication_active] && params[:scheduled_publication_active].to_i == 0
      params[:edition].keys.each do |key|
        if key =~ /^scheduled_publication(\([0-9]i\))?/
          params[:edition].delete(key)
        end
      end
      params[:edition][:scheduled_publication] = nil
    end
  end

  def redirect_to_controller_for_type
    if params[:controller] == 'admin/editions'
      redirect_to admin_edition_path(@edition)
    end
  end

  def publisher
    @publisher ||= Whitehall.edition_services.publisher(@edition)
  end
  helper_method :publisher

  def force_publisher
    @force_publisher ||= Whitehall.edition_services.force_publisher(@edition)
  end
  helper_method :force_publisher

  def deduplicate_specialist_sectors
    if params[:edition] && params[:edition][:secondary_specialist_sector_tags] && params[:edition][:primary_specialist_sector_tag]
      params[:edition][:secondary_specialist_sector_tags] -= [params[:edition][:primary_specialist_sector_tag]]
    end
  end
end
