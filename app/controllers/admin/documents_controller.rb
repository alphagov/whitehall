class Admin::DocumentsController < Admin::BaseController
  before_filter :find_document, only: [:show, :edit, :update, :submit, :revise, :destroy]
  before_filter :prevent_modification_of_unmodifiable_document, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :build_document, only: [:new, :create]
  before_filter :remember_filters, only: [:draft, :submitted, :published]
  before_filter :detect_other_active_editors, only: [:edit]

  def index
    if session[:document_filters]
      redirect_to session[:document_filters]
    elsif current_user.departmental_editor?
      redirect_to action: :submitted, organisation: current_user.organisation
    else
      redirect_to action: :draft, author: current_user
    end
  rescue ActionController::RoutingError => e
    redirect_to action: :draft
  end

  def all
    @documents = filter_documents(document_class.active)
    @page_title = "All Documents"
    @document_state = ''
    render :index
  end

  def draft
    @documents = filter_documents(document_class.draft)
    @page_title = "Draft Documents"
    @document_state = 'draft'
    render :index
  end

  def submitted
    @documents = filter_documents(document_class.submitted)
    @page_title = "Submitted Documents"
    @document_state = 'submitted'
    render :index
  end

  def published
    @documents = filter_documents(document_class.published)
    @page_title = "Published Documents"
    @document_state = 'published'
    render :index
  end

  def rejected
    @documents = filter_documents(document_class.rejected)
    @page_title = "Rejected Documents"
    @document_state = 'rejected'
    render :index
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
    @conflicting_document = Document.find(params[:id])
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
    document = @document.create_draft(current_user)
    if document.persisted?
      redirect_to edit_admin_document_path(document)
    else
      redirect_to edit_admin_document_path(@document.document_identity.unpublished_edition),
        alert: document.errors.full_messages.to_sentence
    end
  end

  def destroy
    redirect_path = @document.submitted? ? submitted_admin_documents_path : admin_documents_path
    @document.delete!
    redirect_to redirect_path, notice: "The document '#{@document.title}' has been deleted"
  end

  private

  def document_class
    Document
  end

  def document_params
    (params[:document] || {}).merge(creator: current_user)
  end

  def build_document
    @document = document_class.new(document_params)
  end

  def find_document
    @document = document_class.find(params[:id])
  end

  def prevent_modification_of_unmodifiable_document
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
      params[:document][:related_document_identity_ids] ||= []
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

  def filter_documents(documents)
    documents = documents.by_type(params[:filter].classify) if params[:filter]
    documents = documents.authored_by(User.find(params[:author])) if params[:author]
    documents = documents.in_organisation(Organisation.find(params[:organisation])) if params[:organisation]
    documents.includes(document_authors: :user).order("updated_at DESC")
  end

  def remember_filters
    session[:document_filters] = params.slice('action', 'filter', 'author', 'organisation')
  end

  def detect_other_active_editors
    RecentDocumentOpening.expunge! if rand(10) == 0
    @recent_openings = @document.active_document_openings.except_editor(current_user)
  end
end
