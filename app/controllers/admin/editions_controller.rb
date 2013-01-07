class Admin::EditionsController < Admin::BaseController
  before_filter :remove_blank_parameters
  before_filter :clear_scheduled_publication_if_not_activated, only: [:create, :update]
  before_filter :find_edition, only: [:show, :edit, :update, :submit, :revise, :reject, :destroy]
  before_filter :limit_edition_access!, only: [:show, :edit, :update, :submit, :revise, :reject, :destroy]
  before_filter :prevent_modification_of_unmodifiable_edition, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :build_edition, only: [:new, :create]
  before_filter :detect_other_active_editors, only: [:edit]
  before_filter :redirect_to_controller_for_type, only: [:show]
  before_filter :build_edition_organisations, only: [:new, :edit]
  before_filter :delete_absent_edition_organisations, only: [:create, :update]

  def index
    if filter && filter.valid?
      session[:document_filters] = params_filters
      render :index
    elsif session_filters.any?
      redirect_to session_filters
    else
      redirect_to default_filters
    end
  rescue ActionController::RoutingError
    redirect_to state: :draft
  end

  def show
  end

  def new
  end

  def create
    if @edition.save
      redirect_to admin_edition_path(@edition), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_dependencies
      render action: "new"
    end
  end

  def edit
    @edition.open_for_editing_as(current_user)
    render :edit
  end

  def update
    if @edition.edit_as(current_user, params[:edition])
      redirect_to admin_edition_path(@edition),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_dependencies
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    build_edition_dependencies
    render action: "edit"
  end

  def revise
    edition = @edition.create_draft(current_user)
    if edition.persisted?
      redirect_to edit_admin_edition_path(edition)
    else
      redirect_to edit_admin_edition_path(@edition.document.unpublished_edition),
        alert: edition.errors.full_messages.to_sentence
    end
  end

  def destroy
    @edition.delete!
    redirect_to admin_editions_path, notice: "The document '#{@edition.title}' has been deleted"
  end

  private

  def edition_class
    Edition
  end

  def edition_params
    (params[:edition] || {}).merge(creator: current_user)
  end

  def build_edition
    @edition = edition_class.new(edition_params)
  end

  def find_edition
    @edition = edition_class.find(params[:id])
  end

  def prevent_modification_of_unmodifiable_edition
    if @edition.unmodifiable?
      notice = "You cannot modify a #{@edition.state} #{@edition.type.titleize}"
      redirect_to admin_edition_path(@edition), notice: notice
    end
  end

  def default_arrays_of_ids_to_empty
    # params[:edition][:organisation_ids] ||= []
    if @edition.can_be_associated_with_topics?
      params[:edition][:topic_ids] ||= []
    end
    if @edition.can_be_associated_with_ministers?
      params[:edition][:ministerial_role_ids] ||= []
    end
    if @edition.can_be_associated_with_role_appointments?
      params[:edition][:role_appointment_ids] ||= []
    end
    if @edition.can_be_associated_with_statistical_data_sets?
      params[:edition][:statistical_data_set_document_ids] ||= []
    end
    if @edition.can_be_related_to_policies?
      params[:edition][:related_document_ids] ||= []
    end
    if @edition.can_be_associated_with_world_locations?
      params[:edition][:world_location_ids] ||= []
    end
    if @edition.can_be_associated_with_mainstream_categories?
      params[:edition][:other_mainstream_category_ids] ||= []
    end
  end

  def build_edition_dependencies
    build_image
    build_edition_organisations
  end

  def build_edition_organisations
    if @edition.errors.any?
      n = @edition.edition_organisations.select { |eo| eo.lead? }.count
      (n...4).each do |i|
        @edition.edition_organisations.build(lead_ordering: i, lead: true)
      end
      n = @edition.edition_organisations.reject { |eo| eo.lead? }.count
      (n...6).each do |i|
        @edition.edition_organisations.build(lead: false)
      end
    else
      n = @edition.lead_edition_organisations.count
      (n...4).each do |i|
        @edition.lead_edition_organisations.build(lead_ordering: i)
      end
      n = @edition.supporting_edition_organisations.count
      (n...6).each do |i|
        @edition.supporting_edition_organisations.build
      end
    end
  end

  def delete_absent_edition_organisations
    return unless params[:edition] && params[:edition][:edition_organisations_attributes]
    params[:edition][:edition_organisations_attributes].each do |p|
      if p[:organisation_id].blank?
        p["_destroy"] = true
      end
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
    if current_user.departmental_editor?
      {organisation: current_user.organisation, state: :submitted}
    else
      {state: :draft, author: current_user}
    end
  end

  def session_filters
    sanitized_filters(session[:document_filters] || {})
  end

  def params_filters
    sanitized_filters(params.slice(:type, :state, :organisation, :author, :page, :title))
  end

  def sanitized_filters(filters)
    valid_states = %w[ active imported draft submitted rejected published scheduled ]
    filters.delete(:state) unless filters[:state].nil? || valid_states.include?(filters[:state].to_s)
    filters
  end

  def filter
    @filter ||= params_filters.any? && EditionFilter.new(edition_class, current_user, params_filters)
  end

  def detect_other_active_editors
    RecentEditionOpening.expunge! if rand(10) == 0
    @recent_openings = @edition.active_edition_openings.except_editor(current_user)
  end

  def remove_blank_parameters
    params.keys.each do |k|
      params.delete(k) if params[k] == ""
    end
  end

  def clear_scheduled_publication_if_not_activated
    if params[:scheduled_publication_active].to_i == 0
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

  class EditionFilter
    attr_reader :options

    def initialize(source, current_user, options={})
      @source, @current_user, @options = source, current_user, options
    end

    def editions
      @editions ||= (
        editions = @source
        editions = editions.accessible_to(@current_user)
        editions = editions.by_type(options[:type].classify) if options[:type]
        editions = editions.__send__(options[:state]) if options[:state]
        editions = editions.authored_by(author) if options[:author]
        editions = editions.in_organisation(organisation) if options[:organisation]
        editions = editions.with_title_containing(options[:title]) if options[:title]
        editions.includes(:authors).order("editions.updated_at DESC")
      ).page(options[:page]).per(page_size)
    end

    def page_title
      "#{ownership} #{edition_state} #{document_type.humanize.pluralize.downcase}#{title_matches}".squeeze(' ')
    end

    def page_size
      50
    end

    def valid?
      author
      organisation
      true
    rescue ActiveRecord::RecordNotFound
      false
    end

    private

    def ownership
      if author && author == @current_user
        "My"
      elsif author
        "#{author.name}'s"
      elsif organisation && organisation == @current_user.organisation
        "My department's"
      elsif organisation
        "#{organisation.name}'s"
      else
        "Everyone's"
      end
    end

    def title_matches
      " that match '#{options[:title]}'" if options[:title]
    end

    def edition_state
      options[:state] unless options[:state] == 'active'
    end

    def document_type
      options[:type].present? ? options[:type] : 'document'
    end

    def organisation
      Organisation.find(options[:organisation]) if options[:organisation]
    end

    def author
      User.find(options[:author]) if options[:author]
    end

  end
end
