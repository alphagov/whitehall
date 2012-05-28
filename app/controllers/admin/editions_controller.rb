class Admin::EditionsController < Admin::BaseController
  before_filter :find_edition, only: [:show, :edit, :update, :submit, :revise, :reject, :destroy]
  before_filter :prevent_modification_of_unmodifiable_edition, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :build_edition, only: [:new, :create]
  before_filter :detect_other_active_editors, only: [:edit]

  def index
    if params_filters.any?
      state = params_filters[:state]
      @editions = EditionFilter.new(document_class, params_filters).editions
      @edition_state = (state == :active) ? 'all' : state.to_s
      @page_title = "#{@edition_state.humanize} Documents"
      session[:document_filters] = params_filters
    elsif session_filters.any?
       redirect_to session_filters
    else
       redirect_to default_filters
    end
  rescue ActionController::RoutingError
    redirect_to state: :draft
  end

  def new
  end

  def create
    if @document.save
      redirect_to admin_document_path(@document), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_image
      render action: "new"
    end
  end

  def edit
    @document.open_for_editing_as(current_user)
  end

  def update
    if @document.edit_as(current_user, params[:document])
      redirect_to admin_document_path(@document),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_image
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_document = Edition.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    build_image
    render action: "edit"
  end

  def submit
    @document.submit!
    redirect_to admin_document_path(@document),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def revise
    edition = @document.create_draft(current_user)
    if edition.persisted?
      redirect_to edit_admin_document_path(edition)
    else
      redirect_to edit_admin_document_path(@document.doc_identity.unpublished_edition),
        alert: edition.errors.full_messages.to_sentence
    end
  end

  def reject
    @document.reject!
    redirect_to new_admin_document_editorial_remark_path(@document),
      notice: "Document rejected; please explain why in an editorial remark"
  end

  def destroy
    redirect_path = @document.submitted? ? admin_documents_path(state: :submitted) : admin_documents_path
    @document.delete!
    redirect_to redirect_path, notice: "The document '#{@document.title}' has been deleted"
  end

  private

  def document_class
    Edition
  end

  def document_params
    (params[:document] || {}).merge(creator: current_user)
  end

  def build_edition
    @document = document_class.new(document_params)
  end

  def find_edition
    @document = document_class.find(params[:id])
  end

  def prevent_modification_of_unmodifiable_edition
    if @document.unmodifiable?
      notice = "You cannot modify a #{@document.state} #{@document.type.titleize}"
      redirect_to admin_document_path(@document), notice: notice
    end
  end

  def default_arrays_of_ids_to_empty
    params[:document][:organisation_ids] ||= []
    if @document.can_be_associated_with_policy_topics?
      params[:document][:policy_topic_ids] ||= []
    end
    if @document.can_be_associated_with_ministers?
      params[:document][:ministerial_role_ids] ||= []
    end
    if @document.can_be_related_to_policies?
      params[:document][:related_doc_identity_ids] ||= []
    end
    if @document.can_be_associated_with_countries?
      params[:document][:country_ids] ||= []
    end
  end

  def build_image
    unless @document.images.any?(&:new_record?)
      image = @document.images.build
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
    valid_states = [:active, :draft, :submitted, :rejected, :published]
    filters.delete(:state) unless filters[:state].nil? || valid_states.include?(filters[:state].to_sym)
    filters
  end

  def detect_other_active_editors
    RecentEditionOpening.expunge! if rand(10) == 0
    @recent_openings = @document.active_edition_openings.except_editor(current_user)
  end

  class EditionFilter
    attr_reader :options

    def initialize(source, options={})
      @source, @options = source, options
    end

    def editions
      editions = @source
      editions = editions.by_type(options[:type].classify) if options[:type]
      editions = editions.__send__(options[:state]) if options[:state]
      editions = editions.authored_by(User.find(options[:author])) if options[:author]
      editions = editions.in_organisation(Organisation.find(options[:organisation])) if options[:organisation]
      editions.includes(:authors).order("updated_at DESC")
    end
  end
end
