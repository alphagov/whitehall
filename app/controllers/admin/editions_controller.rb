class Admin::EditionsController < Admin::BaseController
  include HistoricContentConcern
  include Admin::EditionsHelper

  before_action :remove_blank_parameters
  before_action :clean_edition_parameters, only: %i[create update]
  before_action :clear_scheduled_publication_if_not_activated, only: %i[create update]
  before_action :clear_response_form_file_cache, only: %i[create update]
  before_action :find_edition, only: %i[show edit update revise diff confirm_destroy destroy update_bypass_id update_image_display_option]
  before_action :prevent_modification_of_unmodifiable_edition, only: %i[update]
  before_action :delete_absent_edition_organisations, only: %i[create update]
  before_action :build_national_exclusion_params, only: %i[create update]
  before_action :set_creator_for_review_reminder, only: %i[create update]
  before_action :build_edition, only: %i[new create]
  before_action :detect_other_active_editors, only: %i[edit update]
  before_action :set_edition_defaults, only: :new
  before_action :build_edition_dependencies, only: %i[new edit]
  before_action :forbid_editing_of_historic_content!, only: %i[create edit update destroy revise]
  before_action :enforce_permissions!
  before_action :limit_edition_access!, only: %i[show edit update revise diff destroy]
  before_action :redirect_to_controller_for_type, only: [:show]
  before_action :construct_similar_slug_warning_error, only: %i[edit]

  def enforce_permissions!
    case action_name
    when "index", "topics"
      enforce_permission!(:see, edition_class || Edition)
    when "show"
      enforce_permission!(:see, @edition)
    when "new", "choose_type"
      enforce_permission!(:create, edition_class || Edition)
    when "create"
      enforce_permission!(:create, @edition)
    when "edit", "update", "revise", "diff", "update_bypass_id", "update_image_display_option"
      enforce_permission!(:update, @edition)
    when "destroy", "confirm_destroy"
      enforce_permission!(:delete, @edition)
    when "export", "confirm_export"
      enforce_permission!(:export, edition_class || Edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction, action_name
    end
  end

  def index
    if filter && filter.valid?
      session[:document_filters] = params_filters
      render :index
    elsif session_filters.any?
      display_filter_error_message
      redirect_to session_filters
    else
      display_filter_error_message
      redirect_to default_filters
    end
  end

  def export
    if filter && filter.exportable?
      DocumentListExportWorker.perform_async(params_filters_with_default_state.as_json, current_user.id)
      flash[:notice] = "The document list is being exported"
    else
      flash[:alert] = "The document list is too large for export"
    end
    redirect_to params_filters.merge(action: :index)
  end

  def confirm_export
    filter
  end

  def show
    fetch_version_and_remark_trails

    @edition_taxons = if @edition.requires_taxon?
                        EditionTaxonsFetcher.new(@edition.content_id).fetch
                      else
                        []
                      end

    if @edition.can_be_tagged_to_worldwide_taxonomy?
      @edition_world_taxons = EditionTaxonsFetcher.new(@edition.content_id).fetch_world_taxons
    end
  end

  def new; end

  def create
    if updater.can_perform? && @edition.save
      updater.perform!
      redirect_to show_or_edit_path, saved_confirmation_notice
    else
      build_edition_dependencies
      render :new
    end
  end

  def edit
    @edition.open_for_editing_as(current_user) if @edition.editable?
    fetch_version_and_remark_trails
  end

  def update
    @edition.assign_attributes(edition_params)

    if updater.can_perform? && @edition.save_as(current_user)
      updater.perform!

      if @edition.link_check_report
        LinkCheckerApiService.check_links(@edition, admin_link_checker_api_callback_url)
      end

      redirect_to show_or_edit_path, saved_confirmation_notice
    else
      flash.now[:alert] = updater.failure_reason
      build_edition_dependencies
      fetch_version_and_remark_trails
      construct_similar_slug_warning_error
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    build_edition_dependencies
    render :edit
  end

  def revise
    if @edition.superseded? && @edition.is_latest_edition?
      # There are a number of documents in Whitehall for which the
      # latest edition is also superseded, something of a
      # contradiction.
      #
      # To allow for a way out in this circumstance, find the deleted
      # edition that was probably the one that supersedes this
      # superseded edition, and use that to create the draft.
      probably_last_published_edition =
        Edition
          .unscoped # because we're looking for a deleted edition
          .where(document_id: @edition.document_id)
          .where("id > ?", @edition.id)
          .where(state: :deleted)
          .order(id: :asc)
          .first

      new_draft = probably_last_published_edition.create_draft(
        current_user,
        allow_creating_draft_from_deleted_edition: true,
      )
    else
      new_draft = @edition.create_draft(current_user)
    end

    if new_draft.persisted?
      redirect_to edit_admin_edition_path(new_draft)
    else
      redirect_to edit_admin_edition_path(@edition.document.latest_edition),
                  alert: new_draft.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to show_or_edit_path, alert: e.to_s
  end

  def diff
    audit_trail_entry = edition_class.find(params[:audit_trail_entry_id])
    @audit_trail_entry = LocalisedModel.new(audit_trail_entry, audit_trail_entry.primary_locale)
  end

  def confirm_destroy; end

  def destroy
    edition_deleter = Whitehall.edition_services.deleter(@edition)
    if edition_deleter.perform!
      redirect_to admin_editions_path, notice: "The draft of '#{@edition.title}' has been deleted"
    else
      redirect_to admin_edition_path(@edition), alert: edition_deleter.failure_reason
    end
  end

  def update_bypass_id
    EditionAuthBypassUpdater.new(edition: @edition, current_user:, updater:).call

    redirect_to admin_edition_path(@edition), notice: "New document preview link generated"
  end

private

  def display_filter_error_message
    if filter&.errors&.any?
      flash["html_safe"] = true
      flash[:alert] = filter.errors.join("<br>")
    end
  end

  def fetch_version_and_remark_trails
    @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1, only: params[:only])
  end

  def edition_class
    Edition
  end

  def edition_params
    @edition_params ||= params.fetch(:edition, {}).permit(*permitted_edition_attributes)
  end

  def permitted_edition_attributes
    [
      :title,
      :body,
      :change_note,
      :summary,
      :first_published_at,
      :publication_type_id,
      :scheduled_publication,
      :lock_version,
      :access_limited,
      :alternative_format_provider_id,
      :opening_at,
      :closing_at,
      :external,
      :external_url,
      :minor_change,
      :previously_published,
      :roll_call_introduction,
      :operational_field_id,
      :news_article_type_id,
      :role_appointment_id,
      :speech_type_id,
      :delivered_on,
      :location,
      :person_override,
      :primary_locale,
      :create_foreign_language_only,
      :related_mainstream_content_url,
      :additional_related_mainstream_content_url,
      :corporate_information_page_type_id,
      :political,
      :government_id,
      :read_consultation_principles,
      :all_nation_applicability,
      :speaker_radios,
      :visual_editor,
      :logo_formatted_name,
      {
        all_nation_applicability: [],
        lead_organisation_ids: [],
        supporting_organisation_ids: [],
        organisation_ids: [],
        role_ids: [],
        world_location_ids: [],
        worldwide_organisation_ids: [],
        topic_ids: [],
        topical_event_ids: [],
        related_detailed_guide_ids: [],
        role_appointment_ids: [],
        statistical_data_set_document_ids: [],
        worldwide_organisation_document_ids: [],
        policy_group_ids: [],
        document_collection_group_ids: [],
        consultation_participation_attributes: [
          :id,
          :link_url,
          :email,
          :postal_address,
          {
            consultation_response_form_attributes: [
              :id,
              :title,
              :_destroy,
              :attachment_action,
              { consultation_response_form_data_attributes: %i[id file file_cache] },
            ],
          },
        ],
        call_for_evidence_participation_attributes: [
          :id,
          :link_url,
          :email,
          :postal_address,
          {
            call_for_evidence_response_form_attributes: [
              :id,
              :title,
              :_destroy,
              :attachment_action,
              { call_for_evidence_response_form_data_attributes: %i[id file file_cache] },
            ],
          },
        ],
        default_news_image_attributes: %i[file file_cache id],
        nation_inapplicabilities_attributes: %i[id nation_id alternative_url excluded],
        fatality_notice_casualties_attributes: %i[id personal_details _destroy],
        document_attributes: [
          :id,
          :slug,
          {
            review_reminder_attributes: %i[
              id
              email_address
              review_at
              _destroy
            ],
          },
        ],
        flexible_page_content: {},
      },
      :auth_bypass_id,
      :flexible_page_type,
    ]
  end

  def new_edition_params
    edition_params.merge(creator: current_user)
  end

  def show_or_edit_path
    if params[:save].present?
      [:edit, :admin, @edition]
    else
      admin_edition_path @edition
    end
  end

  def saved_confirmation_notice
    if params[:save].present? || @edition.has_been_tagged? || !@edition.requires_taxon?
      notice = "Your document has been saved"
      html_safe = false
    else
      add_topic_tags = view_context.link_to("add topic tags", edit_admin_edition_tags_path(@edition), class: "govuk-link")
      notice = "Your document has been saved. You need to #{add_topic_tags} before you can publish this document."
      html_safe = true
    end
    { flash: { notice:, html_safe: } }
  end

  def new_edition
    edition_class.new(new_edition_params)
  end

  def build_edition
    edition_locale = edition_params[:primary_locale] || I18n.default_locale
    I18n.with_locale(edition_locale) do
      @edition = LocalisedModel.new(new_edition, edition_locale)
      if @edition.visual_editor.nil?
        @edition.visual_editor = Flipflop.govspeak_visual_editor? && current_user.can_see_visual_editor_private_beta?
      end
    end
  end

  def find_edition
    edition = edition_class.find(params[:id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def build_national_exclusion_params
    return if edition_params["nation_inapplicabilities_attributes"].blank?

    exclusion_params = edition_params["all_nation_applicability"] || []
    edition_params["all_nation_applicability"] = exclusion_params.include?("all_nations") ? "1" : "0"

    build_nation_params(nation_id: 1, checked: exclusion_params.include?("england"))
    build_nation_params(nation_id: 2, checked: exclusion_params.include?("scotland"))
    build_nation_params(nation_id: 3, checked: exclusion_params.include?("wales"))
    build_nation_params(nation_id: 4, checked: exclusion_params.include?("northern_ireland"))
  end

  def build_nation_params(nation_id:, checked:)
    edition_params["nation_inapplicabilities_attributes"][(nation_id - 1).to_s]["excluded"] = checked ? "1" : "0"
    edition_params["nation_inapplicabilities_attributes"][(nation_id - 1).to_s]["alternative_url"] = nil unless checked
  end

  def set_creator_for_review_reminder
    return if edition_params.dig("document_attributes", "review_reminder_attributes").blank?

    edition_params["document_attributes"]["review_reminder_attributes"]["creator_id"] = current_user.id
  end

  def build_edition_dependencies
    @edition.build_document if @edition.document.blank?
    @edition.document.build_review_reminder if @edition.document.review_reminder.blank?
  end

  def set_edition_defaults
    build_default_organisation
    set_default_edition_locations
  end

  def build_default_organisation
    if @edition.can_be_related_to_organisations?
      @edition.edition_organisations.build(lead_ordering: 0, lead: true, organisation: current_user.organisation)
    end
  end

  def set_default_edition_locations
    if current_user.world_locations.any? && @edition.world_locations.none?
      @edition.world_locations = current_user.world_locations
    end
  end

  def delete_absent_edition_organisations
    return if edition_params.empty?

    if edition_params[:lead_organisation_ids]
      edition_params[:lead_organisation_ids] = edition_params[:lead_organisation_ids].reject(&:blank?)
    end
    if edition_params[:supporting_organisation_ids]
      edition_params[:supporting_organisation_ids] = edition_params[:supporting_organisation_ids].reject(&:blank?)
    end
  end

  def default_filters
    { organisation: current_user.organisation.try(:id), state: :active }
  end

  def session_filters
    (session[:document_filters] || {}).to_h
  end

  def params_filters
    params.slice(:type, :state, :organisation, :author, :page, :title, :world_location, :from_date, :to_date, :only_invalid_editions, :only_broken_links, :review_overdue)
          .permit!
          .to_h
  end

  def params_filters_with_default_state
    params_filters.reverse_merge("state" => "active")
  end

  def filter
    @filter ||= Admin::EditionFilter.new(edition_class, current_user, edition_filter_options) if params_filters.any?
  end

  def edition_filter_options
    params_filters_with_default_state
      .symbolize_keys
      .merge(
        include_unpublishing: true,
        include_link_check_report: true,
        include_last_author: true,
      )
      .merge(per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
  end

  def detect_other_active_editors
    RecentEditionOpening.expunge! if rand(10).zero?
    @recent_openings = @edition.active_edition_openings.except_editor(current_user)
  end

  def remove_blank_parameters
    params.reject! { |_, value| value.blank? }
  end

  def clean_edition_parameters
    return if edition_params.empty?

    edition_params[:title].strip! if edition_params[:title]
    edition_params.delete(:primary_locale) if edition_params[:primary_locale].blank? || edition_params[:create_foreign_language_only].blank?
    edition_params.delete(:create_foreign_language_only)
    edition_params[:external_url] = nil if edition_params[:external] == "0"
    edition_params[:change_note] = nil if edition_params[:minor_change] == "true"

    if edition_params[:previously_published] == "false"
      edition_params["first_published_at(1i)"] = ""
      edition_params["first_published_at(2i)"] = ""
      edition_params["first_published_at(3i)"] = ""
    end

    if params[:review_reminder].blank? && edition_params.dig("document_attributes", "review_reminder_attributes").present?
      edition_params["document_attributes"]["review_reminder_attributes"]["_destroy"] = "1"
    end
  end

  def clear_scheduled_publication_if_not_activated
    if params[:scheduled_publication_active] && params[:scheduled_publication_active].to_i.zero?
      edition_params.keys.each do |key|
        if key.match?(/^scheduled_publication(\([0-9]i\))?/)
          edition_params.delete(key)
        end
      end
      edition_params[:scheduled_publication] = nil
    end
  end

  def clear_response_form_file_cache
    response_form_params = edition_params.dig(:consultation_participation_attributes, :consultation_response_form_attributes, :consultation_response_form_data_attributes) || edition_params.dig(:call_for_evidence_participation_attributes, :call_for_evidence_response_form_attributes, :call_for_evidence_response_form_data_attributes)
    if response_form_params&.dig(:file).present? && response_form_params&.dig(:file_cache).present?
      response_form_params.delete(:file_cache)
    end
  end

  def redirect_to_controller_for_type
    if params[:controller] == "admin/editions"
      redirect_to admin_edition_path(@edition)
    end
  end

  def construct_similar_slug_warning_error
    @edition.errors.add(:title, "has been used before on GOV.UK, although the page may no longer exist. Please use another title") if show_similar_slugs_warning?(@edition)
  end

  def updater
    @updater ||= Whitehall.edition_services.draft_updater(@edition, { current_user: })
  end

  def publisher
    @publisher ||= Whitehall.edition_services.publisher(@edition)
  end
  helper_method :publisher

  def force_publisher
    @force_publisher ||= Whitehall.edition_services.force_publisher(@edition)
  end
  helper_method :force_publisher

  def scheduler
    @scheduler ||= Whitehall.edition_services.scheduler(@edition)
  end
  helper_method :scheduler

  def force_scheduler
    @force_scheduler ||= Whitehall.edition_services.force_scheduler(@edition)
  end
  helper_method :force_scheduler
end
