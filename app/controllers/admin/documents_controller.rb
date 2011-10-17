class Admin::DocumentsController < Admin::BaseController
  before_filter :find_document, only: [:show, :edit, :update, :submit, :publish, :revise, :fact_check]

  def index
    @documents = Document.unsubmitted
  end

  def submitted
    @documents = Document.submitted
  end

  def published
    @documents = Document.published
  end

  def new
    @document = document_class.new
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
    flash.now[:alert] = %{This document has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_document = Document.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    render action: "edit"
  end

  def submit
    @document.submit_as(current_user)
    redirect_to admin_document_path(@document),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def publish
    if @document.publish_as(current_user, params[:document][:lock_version])
      redirect_to published_admin_documents_path, notice: "The document #{@document.title} has been published"
    else
      redirect_to admin_document_path(@document), alert: @document.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_document_path(@document), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
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

  private

  def document_class
    @document_class ||= params[:document_type] == "Publication" ? Publication : Policy
  end

  def find_document
    @document = Document.find(params[:id])
  end
end