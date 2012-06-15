class Admin::EditionsController < Admin::BaseController
  before_filter :remove_blank_parameters
  before_filter :find_edition, only: [:show, :edit, :update, :submit, :revise, :reject, :destroy]
  before_filter :prevent_modification_of_unmodifiable_edition, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :build_edition, only: [:new, :create]
  before_filter :detect_other_active_editors, only: [:edit]

  def index
    if params_filters.any?
      @filter = EditionFilter.new(edition_class, params_filters)
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
      build_image
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
      build_image
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    build_image
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
    params[:edition][:organisation_ids] ||= []
    if @edition.can_be_associated_with_topics?
      params[:edition][:topic_ids] ||= []
    end
    if @edition.can_be_associated_with_ministers?
      params[:edition][:ministerial_role_ids] ||= []
    end
    if @edition.can_be_related_to_policies?
      params[:edition][:related_document_ids] ||= []
    end
    if @edition.can_be_associated_with_countries?
      params[:edition][:country_ids] ||= []
    end
  end

  def build_image
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
    sanitized_filters(params.slice(:type, :state, :organisation, :author))
  end

  def sanitized_filters(filters)
    valid_states = %w[ active draft submitted rejected published ]
    filters.delete(:state) unless filters[:state].nil? || valid_states.include?(filters[:state].to_s)
    filters
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

  class EditionFilter
    attr_reader :options

    def initialize(source, options={})
      @source, @options = source, options
    end

    def editions
      @editions ||= (
        editions = @source
        editions = editions.by_type(options[:type].classify) if options[:type]
        editions = editions.__send__(options[:state]) if options[:state]
        editions = editions.authored_by(author) if options[:author]
        editions = editions.in_organisation(organisation) if options[:organisation]
        editions.includes(:authors).order("updated_at DESC")
      )
    end

    def page_title(current_user)
      "#{ownership(current_user)} #{edition_state} #{document_type.humanize.pluralize.downcase}".squeeze(' ')
    end

    private

    def ownership(current_user)
      if author && author == current_user
        "My"
      elsif author
        "#{author.name}'s"
      elsif organisation && organisation == current_user.organisation
        "My department's"
      elsif organisation
        "#{organisation.name}'s"
      else
        "Everyone's"
      end
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
