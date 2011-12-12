class Admin::DocumentsController < Admin::BaseController
  before_filter :find_document, only: [:show, :edit, :update, :submit, :publish, :revise, :fact_check, :destroy]
  before_filter :prevent_modification_of_unmodifiable_document, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :build_document, only: [:new]
  before_filter :remember_filters, only: [:draft, :submitted, :published]

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

  def draft
    @documents = filter_documents(document_class.draft)
    render action: :index
  end

  def submitted
    @documents = filter_documents(document_class.submitted)
  end

  def published
    @documents = filter_documents(document_class.published)
  end

  def rejected
    @documents = filter_documents(document_class.rejected)
  end

  def new
  end

  def create
    @document = document_class.new(params[:document].merge(creator: current_user))
    if @document.save
      redirect_to admin_document_path(@document), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @document.edit_as(current_user, params[:document])
      redirect_to admin_document_path(@document),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_document = Document.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    render action: "edit"
  end

  def submit
    @document.submit!
    redirect_to admin_document_path(@document),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def revise
    document = @document.create_draft(current_user)
    if document.valid?
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

  def build_document
    @document = document_class.new
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
    if @document.can_be_associated_with_policy_areas?
      params[:document][:policy_area_ids] ||= []
    end
    if @document.can_be_associated_with_ministers?
      params[:document][:ministerial_role_ids] ||= []
    end
    if @document.can_be_related_to_other_documents?
      params[:document][:related_document_ids] ||= []
    end
    if @document.can_be_associated_with_countries?
      params[:document][:country_ids] ||= []
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
end
