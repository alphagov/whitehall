class Admin::DocumentsController < Admin::BaseController
  before_filter :find_document, only: [:show, :edit, :update, :submit, :publish, :revise, :fact_check, :destroy]
  before_filter :build_document, only: [:new]

  def index
    @documents = filtered_documents(:unsubmitted)
  end

  def submitted
    @documents = filtered_documents(:submitted)
  end

  def published
    @documents = filtered_documents(:published)
  end

  def new
  end

  def create
    @document = document_class.new(params[:document].merge(author: current_user))
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
    if @document.update_attributes(params[:document])
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
    @document.submit_as(current_user)
    redirect_to admin_document_path(@document),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def revise
    document = @document.create_draft(current_user)
    if document.valid?
      redirect_to edit_admin_document_path(document)
    else
      redirect_to edit_admin_document_path(@document.document_identity.documents.draft.first),
        alert: document.errors.full_messages.to_sentence
    end
  end

  def destroy
    @document.delete!
    redirect_to admin_documents_path, notice: "The document '#{@document.title}' has been deleted"
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

  def filtered_documents(state)
    @document_state = state
    if params[:filter]
      document_class.by_type(params[:filter].classify).send(@document_state)
    else
      document_class.send(@document_state)
    end
  end
end